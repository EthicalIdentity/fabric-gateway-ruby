module Fabric
  #
  # Manages the instantiation and creation of the Gateway::ProposedTransaction Protobuf Message.
  #
  # Adapted from official fabric-gateway SDK ProposalBuilder and hyperledger-fabric-sdk:
  # https://github.com/hyperledger/fabric-gateway/blob/1518e03ed3d6db1b6809e23e61a92744fd18e724/node/src/proposalbuilder.ts
  # https://github.com/kirshin/hyperledger-fabric-sdk/blob/95a5a1a37001852312df25946e960a9ff149207e/lib/fabric/proposal.rb
  class ProposedTransaction
    attr_reader :contract,
                :transaction_name,
                :transaction_context,
                :transient_data,
                :arguments,
                :proposed_transaction

    # Specifies the set of organizations that will attempt to endorse the proposal.
    # No other organizations' peers will be sent this proposal.
    # This is usually used in conjunction with transientData for private data scenarios.
    attr_reader :endorsing_organizations

    def initialize(contract, transaction_name, arguments: [], transient_data: {}, endorsing_organizations: [])
      @contract = contract
      @transaction_name = transaction_name
      @arguments = arguments
      @transient_data = transient_data
      @endorsing_organizations = endorsing_organizations
    end

    #
    # Builds a grpc proposed transaction message
    #
    # @return [Gateway::ProposedTransaction]
    #
    def generate_proposed_transaction
      Gateway::ProposedTransaction.new(
        transaction_id: transaction_context.transaction_id,
        proposal: signed_proposal,
        endorsing_organizations: endorsing_organizations
      )
    end

    def signed_proposal
      Protos::SignedProposal.new(
        proposal: proposal,
        signature: new_signature
      )
    end

    def proposal
      @proposal ||= Protos::Proposal.new header: header.to_proto,
                                         payload: chaincode_proposal.to_proto
    end

    def header
      Common::Header.new channel_header: channel_header.to_proto,
                         signature_header: signature_header.to_proto
    end

    def channel_header
      Common::ChannelHeader.new type: Common::HeaderType::ENDORSER_TRANSACTION,
                                channel_id: channel_name, tx_id: transaction_id,
                                extension: channel_header_extension.to_proto,
                                timestamp: timestamp,
                                version: Constants::CHANNEL_HEADER_VERSION
    end

    def channel_header_extension
      Protos::ChaincodeHeaderExtension.new chaincode_id: chaincode_id
    end

    def chaincode_id
      Protos::ChaincodeID.new name: chaincode_name
    end

    def chaincode_proposal_payload
      chaincode_input = Protos::ChaincodeInput.new args: args
      chaincode_spec = Protos::ChaincodeSpec.new type: Protos::ChaincodeSpec::Type::NODE,
                                                 chaincode_id: chaincode_id,
                                                 input: chaincode_input
      input = Protos::ChaincodeInvocationSpec.new chaincode_spec: chaincode_spec

      Protos::ChaincodeProposalPayload.new input: input.to_proto, TransientMap: transient
    end

    #
    # Returns the current timestamp
    #
    # @return [Google::Protobuf::Timestamp] gRPC timestamp
    #
    def timestamp
      now = Time.now

      @timestamp ||= Google::Protobuf::Timestamp.new seconds: now.to_i, nanos: now.nsec
    end

    def nonce
      @nonce ||= signer.crypto_suite.generate_nonce
    end

    def transaction_id
      @transaction_id ||= signer.crypto_suite.hexdigest(nonce + identity.serialize)
    end

    def signature_header
      Common::SignatureHeader.new creator: signer.serialize, nonce: nonce
    end

    # Dev note: if we have more classes that encapsulate protobuffer messages, consider
    # creating an EncapsulatedPBMessage to hold the message and expose the following methods
    # as common interface.

    #
    # Returns the protobuf message instance
    #
    # @return [Gateway::ProposedTransaction] protobuf message instance
    #
    def as_proto
      proposed_transaction
    end

    #
    # Returns the serialized Protobuf binary form of the proposed transaction
    #
    # @return [String] serialized Protobuf binary form of the proposed transaction
    #
    def to_proto
      proposed_transaction.to_proto
    end

    #
    # Returns the serialized JSON form of the proposed transaction
    #
    # @param [Hash] options JSON serialization options @see https://ruby-doc.org/stdlib-2.6.3/libdoc/json/rdoc/JSON.html#method-i-generate
    #
    # @return [String] serialized JSON form of the proposed transaction
    #
    def to_json(options = {})
      proposed_transaction.to_json(options)
    end
  end
end
