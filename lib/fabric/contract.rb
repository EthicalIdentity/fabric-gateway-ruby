# frozen_string_literal: true

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

    #
    # Evaluate a transaction function and return its results. A transaction proposal will be evaluated on endorsing
    # peers but the transaction will not be sent to the ordering service and so will not be committed to the ledger.
    # This can be used for querying the world state.
    #
    # @param [String] transaction_name
    # @param [Array] arguments array of arguments to pass to the transaction
    #
    # @return [String] raw payload of the transaction response
    #
    def evaluate_transaction(transaction_name, arguments = [])
      evaluate(transaction_name, { arguments: arguments })
    end

    #
    # Submit a transaction to the ledger and return its result only after it is committed to the ledger. The
    # transaction function will be evaluated on endorsing peers and then submitted to the ordering service to be
    # committed to the ledger.
    #
    #
    # @param [String] transaction_name
    # @param [Array] arguments array of arguments to pass to the transaction
    #
    # @return [String] raw payload of the transaction response
    #
    def submit_transaction(transaction_name, arguments = [])
      submit(transaction_name, { arguments: arguments })
    end

    #
    # Evaluate a transaction function and return its result. This method provides greater control over the transaction
    # proposal content and the endorsing peers on which it is evaluated. This allows transaction functions to be
    # evaluated where the proposal must include transient data, or that will access ledger data with key-based
    # endorsement policies.
    #
    # @param [String] transaction_name
    # @param [Hash] proposal_options
    # @option proposal_options [Array] :arguments array of arguments to pass to the transaction
    # @option proposal_options [Hash] :transient_data Private data passed to the transaction function but not recorded
    #                                                 on the ledger.
    # @option proposal_options [Array] :endorsing_organizations Specifies the set of organizations that will attempt to
    #                                                           endorse the proposal.
    #
    # @return [String] Raw evaluation response payload
    #
    def evaluate(transaction_name, proposal_options = {})
      new_proposal(transaction_name, **proposal_options).evaluate
    end

    #
    # Submit a transaction to the ledger and return its result only after it is committed to the ledger. The
    # transaction function will be evaluated on endorsing peers and then submitted to the ordering service to be
    # committed to the ledger.
    #
    # @param [String] transaction_name
    # @param [Hash] proposal_options
    # @option proposal_options [Array] :arguments array of arguments to pass to the transaction
    # @option proposal_options [Hash] :transient_data Private data passed to the transaction function but not recorded
    #                                                 on the ledger.
    # @option proposal_options [Array] :endorsing_organizations Specifies the set of organizations that will attempt to
    #                                                           endorse the proposal.
    #
    # @return [String] Raw evaluation response payload
    #
    def submit(transaction_name, proposal_options = {})
      transaction = new_proposal(transaction_name, **proposal_options).endorse
      transaction.submit

      transaction.result
    end

    #
    # @todo: unimplemented, not sure if this can be implemented because
    # the official grpc ruby client does not support non-blocking async
    # calls (https://github.com/grpc/grpc/issues/10973)
    #
    # not 100% sure if grpc support is necessary for this.
    #
    def submit_async
      raise NotYetImplemented
    end

    #
    # Creates a transaction proposal that can be evaluated or endorsed. Supports off-line signing flow.
    #
    # @param [String] transaction_name transaction name (first argument unshifted into the argument array)
    # @param [Array<String>] arguments array of arguments to pass to the transaction
    # @param [Hash] transient_data Private data passed to the transaction function but not recorded on the ledger.
    # @param [Array] endorsing_organizations Specifies the set of organizations that will attempt to endorse the
    #                                        proposal.
    #
    # @return [Fabric::Proposal] signed unexecuted proposal
    #
    def new_proposal(transaction_name, arguments: [], transient_data: {}, endorsing_organizations: [])
      proposed_transaction = ProposedTransaction.new(
        self,
        qualified_transaction_name(transaction_name),
        arguments: arguments,
        transient_data: transient_data,
        endorsing_organizations: endorsing_organizations
      )
      Proposal.new(proposed_transaction)
    end

    #
    # Generates the qualified transaction name for the contract. (prepends the contract name to the transaction name if
    # contract name is set)
    #
    # @param [string] transaction_name
    #
    # @return [string] qualified transaction name
    #
    def qualified_transaction_name(transaction_name)
      contract_name.nil? || contract_name.empty? ? transaction_name : "#{contract_name}:#{transaction_name}"
    end
  end
end
