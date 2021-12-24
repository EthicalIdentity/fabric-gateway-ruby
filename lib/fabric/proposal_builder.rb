module Fabric
  #
  # Utility class for generating a proposal message.
  #
  # Adapted from official fabric-gateway SDK and hyperledger-fabric-sdk:
  # https://github.com/kirshin/hyperledger-fabric-sdk/blob/95a5a1a37001852312df25946e960a9ff149207e/lib/fabric/proposal.rb
  class ProposalBuilder
    attr_reader :client,
                :signer,
                :channel_name,
                :chaincode_name,
                :transaction_name,
                :transaction_context,
                :transient_data,
                :arguments

    # Specifies the set of organizations that will attempt to endorse the proposal.
    # No other organizations' peers will be sent this proposal.
    # This is usually used in conjunction with transientData for private data scenarios.
    attr_reader :endorsing_organizations

    def initialize(client, signer, channel_name, chaincode_name, transaction_name, arguments = [], transient_data = {}, endorsing_organizations = [])
      @client = client
      @signer = signer
      @channel_name = channel_name
      @chaincode_name = chaincode_name
      @transaction_name = transaction_name
      @arguments = arguments
      @transient_data = transient_data
      @endorsing_organizations = endorsing_organizations
    end

    #
    # Builds a proposal message.
    #
    # @return [Fabric::Proposal] new Proposal
    #
    def build
      Proposal.new(client, signer, channel_name, proposed_transaction)
    end

    #
    # Builds a grpc proposed transaction message
    #
    # @return [Gateway::ProposedTransaction]
    #
    def proposed_transaction
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
  end
end
