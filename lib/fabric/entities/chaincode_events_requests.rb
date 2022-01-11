# frozen_string_literal: true

module Fabric
  #
  # Encapsulates a Chaincode Events Request protobuf message
  #
  class ChaincodeEventsRequest
    attr_reader :contract,
                :start_block

    # @!parse include Fabric::Accessors::Network
    # @!parse include Fabric::Accessors::Gateway
    include Fabric::Accessors::Contract

    #
    # Creates a new ChaincodeEventsRequest
    #
    # @param [Fabric::Contract] contract an instance of a contract
    # @param [Integer] start_block Block number at which to start reading chaincode events.
    #
    def initialize(contract, start_block: nil)
      @contract = contract
      @start_block = start_block
    end

    #
    # Returns the signed request
    #
    # @return [Gateway::SignedChaincodeEventsRequest] generated signed request
    #
    def signed_request
      @signed_request ||= ::Gateway::SignedChaincodeEventsRequest.new(request: chaincode_events_request.to_proto)
    end

    #
    # Returns the chaincode events request
    #
    # @return [Gateway::ChaincodeEventsRequest] chaincode events request - controls what events are returned
    #   from a chaincode events request
    #
    def chaincode_events_request
      @chaincode_events_request ||= new_chaincode_events_request
    end

    #
    # Get the serialized chaincode events request protobuffer message.
    #
    # @return [String] protobuffer serialized chaincode events request
    #
    def request_bytes
      signed_request.request
    end

    #
    # Get the digest of the chaincode events request. This is used to generate a digital signature.
    #
    # @return [String] chaincode events request digest
    #
    def request_digest
      Fabric.crypto_suite.digest(request_bytes)
    end

    #
    # Sets the signed request signature.
    #
    # @param [String] signature
    #
    # @return [void]
    #
    def signature=(signature)
      signed_request.signature = signature
    end

    #
    # Returns the signed_request signature
    #
    # @return [String] Raw byte string signature
    #
    def signature
      signed_request.signature
    end

    #
    # Sign the chaincode events request; Noop if request already signed.
    #
    # @return [void]
    #
    def sign
      return if signed?

      self.signature = signer.sign(request_bytes)
    end

    #
    # Checks if the signed chaincode events has been signed.
    #
    # @return [Boolean] true if the signed chaincode events has been signed; otherwise false.
    #
    def signed?
      !signed_request.signature.empty?
    end

    #
    # Get chaincode events emitted by transaction functions of a specific chaincode.
    #
    # @see Fabric::Client#chaincode_events Fabric::Client#chaincode_events - explanation of the different return types
    #   and example usage.
    # @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:server_streamer Call options for options parameter
    #
    # @param [Hash] options gRPC call options (merged with default_call_options from initializer)
    # @yield [chaincode_event] loops through the chaincode events
    # @yieldparam [Gateway::ChaincodeEventsResponse] chaincode_event the chaincode event
    #
    # @return [Enumerator|GRPC::ActiveCall::Operation|nil] Dependent on parameters passed;
    #   please see Fabric::Client#get_chaincode_events
    #
    def get_events(options = {}, &block)
      sign

      client.chaincode_events(signed_request, options, &block)
    end

    private

    #
    # Generates a new chaincode events request
    #
    # @return [Gateway::ChaincodeEventsRequest] chaincode events request - controls what events are returned
    #
    def new_chaincode_events_request
      ::Gateway::ChaincodeEventsRequest.new(
        channel_id: network_name,
        chaincode_id: chaincode_name,
        identity: signer.to_proto,
        start_position: start_position
      )
    end

    #
    # Generates the start_position for the chaincode events request or returns the cached start_position
    #
    # @return [Orderer::SeekPosition] start position for the chaincode events request
    #
    def start_position
      @start_position ||= new_start_position
    end

    #
    # Generates the start position for the chaincode events request; if no start_block is specified,
    # generates a seek next commit start position, otherwise generates a start_position to the start_block
    #
    # @return [Orderer::SeekPosition] start position for the chaincode events request
    #
    def new_start_position
      specified = nil
      next_commit = nil

      if start_block
        specified = ::Orderer::SeekSpecified.new(number: start_block)
      else
        next_commit = ::Orderer::SeekNextCommit.new
      end
      Orderer::SeekPosition.new(specified: specified, next_commit: next_commit)
    end
  end
end
