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
    # @return [Protos::SignedProposal|nil] SignedProposal message
    #
    def proposal
      proposed_transaction.proposal
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
      signer.digest(proposal.to_proto)
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

    def evaluate
      # TODO: evaluate proposal
    end

    def endorse
      # TODO: endorse proposal
    end

    def new_evaluate_request
      # TODO
    end

    def new_endorse_request
      # TODO
    end

    def new_prepared_transaction
      # TODO
      # used in endorse
    end
  end
end
