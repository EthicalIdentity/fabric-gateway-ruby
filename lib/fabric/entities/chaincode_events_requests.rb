module Fabric
  #
  # Encapsulates a Chaincode Events Request protobuf message
  # TODO: TEST ME!
  # @todo this needs to be tested
  #
  class ChaincodeEventsRequest
    attr_reader :contract,
                :start_block

    # @!parse include Fabric::Accessors::Network
    # @!parse include Fabric::Accessors::Gateway
    include Fabric::Accessors::Contract

    def initialize(contract, start_block: nil)
      @contract = contract
      @start_block = start_block
    end

    def signed_request
      @signed_request ||= ::Gateway::SignedChaincodeEventsRequest.new(request: chaincode_events_request.to_proto)
    end

    def chaincode_events_request
      @chaincode_events_request ||= new_chaincode_events_request
    end

    def request_digest
      Fabric.crypto_suite.digest(signed_request.request)
    end

    def signature=(signature)
      signed_request.signature = signature
    end

    def sign
      return if signed?

      self.signature = signer.sign(signed_request.request)
    end

    def signed?
      !signed_request.signature.empty?
    end

    def get_events(options = {}, &block)
      sign

      client.chaincode_events(signed_request, options, &block)
    end

    private

    def new_chaincode_events_request
      ::Gateway::ChaincodeEventsRequest.new(
        channel_id: network_name,
        chaincode_id: chaincode_name,
        identity: signer.to_proto,
        start_position: start_position
      )
    end

    def start_position
      @start_position ||= new_start_position
    end

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
