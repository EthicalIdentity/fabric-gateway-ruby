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
      @contract = contract
      @proposed_transaction = proposed_transaction
    end

    #
    # Serialized bytes of the proposal message in proto3 format.
    #
    # @return [String] Binary representation of the proposal message.
    #
    def to_bytes
      proposed_transaction.as_proto
    end

    def digest
      signer.digest(proposed_transaction)
    end

    def transaction_id
      proposed_transaction.transaction_id
    end

    #
    # Returns the proposal message as a gRPC Message class
    #
    # @return [Protos::SignedProposal|nil] SignedProposal message
    #
    def proposal
      proposed_transaction.proposal
    end
  end
end
