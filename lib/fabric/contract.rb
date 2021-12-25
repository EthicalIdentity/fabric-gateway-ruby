module Fabric
  #
  # Contract represents a smart contract, and allows applications to:
  #
  # - Evaluate transactions that query state from the ledger using the EvaluateTransaction() method.
  #
  # - Submit transactions that store state to the ledger using the SubmitTransaction() method.
  #
  # For more complex transaction invocations, such as including transient data, transactions can be evaluated or
  # submitted using the Evaluate() or Submit() methods respectively. The result of a submitted transaction can be
  # accessed prior to its commit to the ledger using SubmitAsync().
  #
  # By default, proposal, transaction and commit status messages will be signed using the signing implementation
  # specified when connecting the Gateway. In cases where an external client holds the signing credentials, a signing
  # implementation can be omitted when connecting the Gateway and off-line signing can be carried out by:
  #
  # 1. Returning the serialized proposal, transaction or commit status   along with its digest to the client for
  # them to generate a signature.
  #
  # 2. With the serialized message and signature received from the client to create a signed proposal, transaction or
  # commit using the Gateway's NewSignedProposal(), NewSignedTransaction() or NewSignedCommit() methods respectively.
  #
  class Contract
    attr_reader :network, :chaincode_name, :contract_name

    def initialize(network, chaincode_name, contract_name = '')
      @network = network
      @chaincode_name = chaincode_name
      @contract_name = contract_name
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

    # @TODO: Implement Me!
    def evaluate_transaction
      raise NotYetImplemented
    end

    # @TODO: Implement Me!
    def submit_transaction
      raise NotYetImplemented
    end

    # @TODO: Implement Me!
    def evaluate
      raise NotYetImplemented
    end

    # @TODO: Implement Me!
    def submit
      raise NotYetImplemented
    end

    #
    # Creates a fully prepared proposal for the given transaction parameters
    # based on the current state of the system.
    #
    # @param [String] transaction_name transaction name (first argument unshifted into the argument array)
    # @param [Array<String>] arguments array of arguments to pass to the transaction
    # @param [Hash] transient_data Private data passed to the transaction function but not recorded on the ledger.
    # @param [Array<Type>] endorsing_organizations Specifies the set of organizations that will attempt to endorse the proposal.
    #
    # @return [Fabric::Proposal] signed unexecuted proposal
    #
    def new_proposal(transaction_name, arguments: [], transient_data: {}, endorsing_organizations: [])
      proposed_transaction = ProposedTransaction.new(
        self,
        transaction_name,
        arguments: arguments,
        transient_data: transient_data,
        endorsing_organizations: endorsing_organizations
      )
      Proposal.new(proposed_transaction)
    end

    # @TODO: untested and currently unused.
    def qualified_transaction_name(transaction_name)
      contract_name.nil? || contract_name.empty? ? transaction_name : "#{contract_name}:#{transaction_name}"
    end
  end
end
