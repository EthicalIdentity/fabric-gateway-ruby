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
    # @todo original SDK has getChaincodeEvents and newChaincodeEventsRequest methods
    # @see https://github.com/hyperledger/fabric-gateway/blob/08118cf0a792898925d0b2710b0a9e7c5ec23228/node/src/network.ts
    # @see https://github.com/hyperledger/fabric-gateway/blob/main/pkg/client/network.go
    #
    # @return [?] ?
    #
    def new_chaincode_events
      raise NotYetImplemented
    end

    #
    # @todo original SDK has getChaincodeEvents and newChaincodeEventsRequest methods
    # @see https://github.com/hyperledger/fabric-gateway/blob/08118cf0a792898925d0b2710b0a9e7c5ec23228/node/src/network.ts
    # @see https://github.com/hyperledger/fabric-gateway/blob/main/pkg/client/network.go
    #
    # @return [?] ?
    #
    def new_chaincode_events_request
      raise NotImplementedError
    end
  end
end
