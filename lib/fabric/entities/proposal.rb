# frozen_string_literal: true

module Fabric
  #
  # Proposal represents a transaction proposal that can be sent to peers for endorsement or evaluated as a query.
  #
  # Combined ProposalBuilder with Proposal. Utilizing instance variables and functions in proposal seem adaquate enough
  # to fully create the proposal. ProposalBuilder did not seem like a native ruby design pattern.
  class Proposal
    attr_reader :proposed_transaction

    #
    # Instantiates a new Proposal
    #
    # @param [Fabric::ProposedTransaction] proposed_transaction ProposedTransaction container class
    #
    def initialize(proposed_transaction)
      @proposed_transaction = proposed_transaction
    end

    def contract
      @proposed_transaction.contract
    end

    def network
      contract.network
    end

    def client
      network.client
    end

    def signer
      network.signer
    end

    def gateway
      network.gateway
    end

    def network_name
      network.name
    end

    def contract_name
      contract.contract_name
    end

    def chaincode_name
      contract.chaincode_name
    end

    def transaction_id
      proposed_transaction.transaction_id
    end

    #
    # Returns the proposal message as a protobuf Message object.
    #
    # @return [Protos::Proposal|nil] Proposal message
    #
    def proposal
      proposed_transaction.proposal
    end

    #
    # Returns the signed proposal
    #
    # <rant>
    # Fabric message naming scheme is a mess:
    # ProposedTransaction has a Proposal which is a SignedProposal
    #               which has a Proposal which is a Proposal
    # so.... which proposal do you want to access? Adding this function for clarity
    # </rant>
    #
    # @return [Protos::SignedProposal|nil] SignedProposal message
    #
    def signed_proposal
      proposed_transaction.proposed_transaction.proposal
    end

    #
    # Serialized bytes of the proposal message in proto3 format.
    #
    # @return [String] Binary representation of the proposal message.
    #
    def to_proto
      proposed_transaction.to_proto
    end

    #
    # Proposal digest which can be utilized for offline signing.
    # If signing offline, call signature= to set signature once
    # computed.
    #
    # @return [String] raw binary digest of the proposal message.
    #
    def digest
      Fabric.crypto_suite.digest(proposal.to_proto)
    end

    #
    # Sets the signature of the signed proposal in the proposed transaction
    #
    # @param [String] signature raw byte string signature of the proposal message
    #                 (should be the signature of the proposed message digest)
    #
    def signature=(signature)
      proposed_transaction.signed_proposal.signature = signature
    end

    #
    # Returns the signed proposal signature
    #
    # @return [String] Raw byte string signature
    #
    def signature
      proposed_transaction.signed_proposal.signature
    end

    #
    # Returns true if the signed proposal has a signature
    #
    # @return [Boolean] true|false
    #
    def signed?
      # signature cannot be nil because google protobuf won't let it
      !proposed_transaction.signed_proposal.signature.empty?
    end

    #
    # Utilizes the signer to sign the proposal message if it has not been signed yet.
    #
    def sign
      return if signed?

      self.signature = signer.sign proposal.to_proto
    end

    #
    # Evaluate the transaction proposal and obtain its result, without updating the ledger. This runs the transaction
    # on a peer to obtain a transaction result, but does not submit the endorsed transaction to the orderer to be
    # committed to the ledger.
    #
    # @param [Hash] options gRPC call options @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @return [String] The result returned by the transaction function
    #
    def evaluate(options = {})
      sign

      evaluate_response = client.evaluate(new_evaluate_request, options)
      evaluate_response.result.payload
    end

    #
    # Obtain endorsement for the transaction proposal from sufficient peers to allow it to be committed to the ledger.
    #
    # @todo - please test me
    #
    # @param [Hash] options gRPC call options @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @return [Fabric::Transaction] An endorsed transaction that can be submitted to the ledger.
    #
    def endorse(options = {})
      sign
      endorse_response = client.endorse(new_endorse_request, options)

      raise Fabric::Error, 'Missing transaction envelope' if endorse_response.prepared_transaction.nil?

      prepared_transaction = new_prepared_transaction(endorse_response.prepared_transaction)

      Fabric::Transaction.new(network, prepared_transaction)
    end

    #
    # Generates an evaluate request from this proposal.
    #
    # @return [Gateway::EvaluateRequest] evaluation request with the current proposal
    #
    def new_evaluate_request
      ::Gateway::EvaluateRequest.new(
        channel_id: network_name,
        proposed_transaction: signed_proposal,
        target_organizations: proposed_transaction.endorsing_organizations
      )
    end

    #
    # Creates a new endorse request from this proposal.
    #
    # @todo - test me!
    # @return [Gateway::EndorseRequest] EndorseRequest protobuf message
    #
    def new_endorse_request
      ::Gateway::EndorseRequest.new(
        transaction_id: transaction_id,
        channel_id: network_name,
        proposed_transaction: signed_proposal,
        endorsing_organizations: proposed_transaction.endorsing_organizations
      )
    end

    #
    # Creates a new prepared transaction from a transaction envelope.
    #
    # @todo - test me!
    # @param [Common::Envelope] envelope transaction envelope
    #
    # @return [Gateway::PreparedTransaction] prepared transaction protobuf message
    #
    def new_prepared_transaction(envelope)
      ::Gateway::PreparedTransaction.new(
        transaction_id: transaction_id,
        envelope: envelope
      )
    end
  end
end
