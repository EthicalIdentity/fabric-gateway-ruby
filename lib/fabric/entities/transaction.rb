module Fabric
  #
  # Represents an endorsed transaction that can be submitted to the orderer for commit to the ledger,
  # query the transaction results and its commit status.
  #
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

    #
    # Creates a new Transaction instance.
    #
    # @param [Fabric::Network] network
    # @param [Gateway::PreparedTransaction] prepared_transaction
    #
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
      raise Fabric::CommitError, status if check_status && !status.successful

      envelope.result
    end

    #
    # Returns the transaction ID from the prepared transaction.
    #
    # @return [String] transaction_id
    #
    def transaction_id
      prepared_transaction.transaction_id
    end

    #
    # Submit the transaction to the orderer to be committed to the ledger.
    #
    # @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @param [Hash] options gRPC call options
    #
    # @return [Fabric::Transaction] self
    def submit(options = {})
      sign_submit_request

      client.submit(new_submit_request, options)

      self
    end

    #
    # Sign the transaction envelope.
    #
    # @return [void]
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

    #
    # Digest to be signed to support offline signing of the submit request
    #
    # @return [String] digest of the submit request
    #
    def submit_request_digest
      envelope.payload_digest
    end

    #
    # Sets the submit request signature. This is used to support offline signing of the submit request.
    #
    # @param [String] signature
    #
    # @return [void]
    #
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

    #
    # Digest to be signed to support offline signing of the commit status request
    #
    # @return [String] digest of the commit status request
    #
    def status_request_digest
      Fabric.crypto_suite.digest(signed_commit_status_request.request)
    end

    #
    # Sets the status request signature. This is used to support offline signing of the commit status request.
    #
    # @param [String] signature
    #
    # @return [void]
    #
    def status_request_signature=(signature)
      signed_commit_status_request.signature = signature
    end

    #
    # Returns true if the signed commit status request has been signed.
    #
    # @return [Boolean] true if signed; false otherwise
    #
    def status_request_signed?
      !signed_commit_status_request.signature.empty?
    end

    #
    # Sign the signed commit status request
    #
    # @return [Fabric::Transaction] self
    #
    def sign_status_request
      return if status_request_signed?

      signature = signer.sign(signed_commit_status_request.request)
      signed_commit_status_request.signature = signature

      self
    end

    #
    # Returns the current instance of the signed commit status request. Necessary so we can keep the state of the signature
    # in the transaction object.
    #
    # @return [Gateway::SignedCommitStatusRequest] signed commit status request
    #
    def signed_commit_status_request
      @signed_commit_status_request ||= new_signed_commit_status_request
    end

    private

    #
    # Actual status query call used by status method.
    #
    # @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @param [Hash] options gRPC call options
    #
    # @return [Fabric::Status] status of the committed transaction
    #
    def query_status(options = {})
      sign_status_request

      commit_status_response = client.commit_status(signed_commit_status_request, options)
      new_status(commit_status_response)
    end

    #
    # Generates a new signed commit status request
    #
    # @return [Gateway::SignedCommitStatusRequest] signed commit status request protobuf message
    #
    def new_signed_commit_status_request
      ::Gateway::SignedCommitStatusRequest.new(
        request: new_commit_status_request.to_proto
      )
    end

    #
    # Generates a new commit status request
    #
    # @return [Gateway::CommitStatusRequest] commit status request protobuf message
    #
    def new_commit_status_request
      ::Gateway::CommitStatusRequest.new(
        channel_id: network_name,
        transaction_id: transaction_id,
        identity: signer.to_proto
      )
    end

    #
    # Generates a new submit request.
    #
    # @return [Gateway::SubmitRequest] submit request protobuf message
    #
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
