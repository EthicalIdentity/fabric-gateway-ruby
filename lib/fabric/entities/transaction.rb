module Fabric
  #
  # Represents an endorsed transaction that can be submitted to the orderer for commit to the ledger,
  # query the transaction results and its commit status.
  #
  # @todo - test me!
  class Transaction
    attr_reader :network

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

    # @return [Gateway::PreparedTransaction] Prepared Transaction
    attr_reader :prepared_transaction

    # @return [Fabric::Envelope]
    attr_reader :envelope

    def initialize(network, prepared_transaction)
      @network = network
      @prepared_transaction = prepared_transaction
      @envelope = Envelope.new(prepared_transaction.envelope)
    end

    #
    # Get the transaction result. This is obtained during the endorsement process when the transaction proposal is
    # run on endorsing peers.
    #
    # @param [boolean] check_status set to true to raise exception if transaction has not yet been committed
    #
    # @return [String] Raw transaction result
    #
    def result(check_status: true)
      check_status ? committed_result : envelope.result
    end

    def committed_result
      raise Fabric::CommitError, status unless status.successful

      envelope.result
    end

    # @todo - test me!
    def transaction_id
      prepared_transaction.transaction_id
    end

    #
    # Represents an endorsed transaction that can be submitted to the orderer for commit to the ledger.
    #
    # @param [<Type>] options <description>
    # @option options [<Type>] :<key> <description>
    # @option options [<Type>] :<key> <description>
    # @option options [<Type>] :<key> <description>
    #
    # @return [<Type>] <description>
    def submit(options = {})
      sign_submit_request

      client.submit(new_submit_request, options)

      self
    end

    def sign_submit_request
      return if submit_request_signed?

      signature = signer.sign(envelope.payload_bytes)
      self.submit_request_signature = signature
    end

    #
    # Returns true if the transaction envelope has been signed.
    #
    # @return [Boolean] true if signed; false otherwise
    #
    def submit_request_signed?
      @envelope.signed?
    end

    # @todo - must complete this to support offline signing
    # the submit request must be created without being signed
    # and allow code to be injected for signing the request
    def submit_request_digest
      envelope.payload_digest
    end

    def submit_request_signature=(signature)
      envelope.signature = signature
    end

    #
    # Get status of the committed transaction. If the transaction has not yet committed, this method blocks until the
    # commit occurs. If status is already queried, this returns status from cache and does not make additional queries.
    #
    # @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @param [Hash] options gRPC call options
    #
    # @return [Fabric::Status] status of the committed transaction
    #
    def status(options = {})
      @status ||= query_status(options)
    end

    # @todo - must complete this to support offline signing
    # the submit request must be created without being signed
    # and allow code to be injected for signing the request
    def status_request_digest
      Fabric.crypto_suite.digest(signed_commit_status_request.request)
    end

    def status_request_signature=(signature)
      signed_commit_status_request.signature = signature
    end

    def status_request_signed?
      !signed_commit_status_request.signature.empty?
    end

    def sign_status_request
      return if status_request_signed?

      signature = signer.sign(signed_commit_status_request.request)
      signed_commit_status_request.signature = signature
    end

    def signed_commit_status_request
      @signed_commit_status_request ||= new_signed_commit_status_request
    end

    private

    #
    # <Description>
    #
    # @param [<Type>] options <description>
    #
    # @return [<Type>] <description>
    #
    def query_status(options = {})
      sign_status_request

      commit_status_response = client.commit_status(signed_commit_status_request, options)
      new_status(commit_status_response)
    end

    def new_signed_commit_status_request
      ::Gateway::SignedCommitStatusRequest.new(
        request: new_commit_status_request.to_proto
      )
    end

    def new_commit_status_request
      ::Gateway::CommitStatusRequest.new(
        channel_id: network_name,
        transaction_id: transaction_id,
        identity: signer.to_proto
      )
    end

    def new_submit_request
      ::Gateway::SubmitRequest.new(
        transaction_id: transaction_id,
        channel_id: network_name,
        prepared_transaction: envelope.envelope
      )
    end

    #
    # New Status from CommitStatusResponse
    #
    # @param [Gateway::CommitStatusResponse] response commit status response
    #
    # @return [Fabric::Status] transaction status
    #
    def new_status(response)
      Fabric::Status.new(
        transaction_id,
        response.block_number,
        Fabric::Status::TRANSACTION_STATUSES[response.result]
      )
    end
  end
end
