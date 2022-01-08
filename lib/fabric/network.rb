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
    # @return [ #<Enumerator: #<GRPC::ActiveCall>] ?
    #
    def new_chaincode_events(contract, start_block: nil, call_options: {}, &block)
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
    # @return [Fabric::ChaincodeEventsRequest] Encapsulated ChaincodeEventsRequest
    #
    def new_chaincode_events_request(contract, start_block: nil)
      ChaincodeEventsRequest.new(contract, start_block: start_block)
    end
  end
end
