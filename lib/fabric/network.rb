# frozen_string_literal: true

module Fabric
  #
  # Network represents a blockchain network, or Fabric channel. The Network can be used to access deployed smart
  # contracts, and to listen for events emitted when blocks are committed to the ledger.
  #
  # JChan & THowe believe this should be called a Channel, however Hyperledger Fabric has decided upon the terminology
  # network - https://github.com/hyperledger/fabric-gateway/issues/355#issuecomment-997888071
  #
  class Network
    attr_reader :gateway, :name

    # @!parse include Fabric::Accessors::Gateway
    include Fabric::Accessors::Gateway

    def initialize(gateway, name)
      @gateway = gateway
      @name = name
    end

    #
    # Creates a new contract instance
    #
    # @param [string] chaincode_name name of the chaincode
    # @param [string] contract_name optional name of the contract
    #
    # @return [Fabric::Contract] new contract instance
    #
    def new_contract(chaincode_name, contract_name = '')
      Contract.new(self, chaincode_name, contract_name)
    end

    #
    # Get chaincode events emitted by transaction functions of a specific chaincode.
    #
    # @see Fabric::Client#chaincode_events Fabric::Client#chaincode_events - explanation of the different return types
    #   and example usage.
    # @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:server_streamer Call options for options parameter
    #
    # @param [Fabric::Contract] contract the chaincode to listen for events on
    # @param [Integer] start_block Block number at which to start reading chaincode events.
    # @param [Hash] options gRPC call options (merged with default_call_options from initializer)
    # @yield [chaincode_event] loops through the chaincode events
    # @yieldparam chaincode_event [Gateway::ChaincodeEventsResponse] the chaincode event
    #
    # @return [Enumerator|GRPC::ActiveCall::Operation|nil] Dependent on parameters passed;
    #   please see Fabric::Client#get_chaincode_events
    #
    def chaincode_events(contract, start_block: nil, call_options: {}, &block)
      new_chaincode_events_request(contract, start_block: start_block).get_events(call_options, &block)
    end

    #
    # Create a request to receive chaincode events emitted by transaction functions of a specific chaincode. Supports
    # off-line signing flow.
    #
    # @note I'm lying. I just copy and pasted the description from the node SDK. Offline signing should work, but it has
    #   not been explicitly tested.
    # @todo Test off-line signing flow.
    #
    # @param [Fabric::Contract] contract the chaincode to listen for events on
    # @param [Integer] start_block Block number at which to start reading chaincode events.
    # @return [Fabric::ChaincodeEventsRequest] Encapsulated ChaincodeEventsRequest
    #
    def new_chaincode_events_request(contract, start_block: nil)
      ChaincodeEventsRequest.new(contract, start_block: start_block)
    end
  end
end
