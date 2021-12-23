# frozen_string_literal: true

module Fabric
  #
  # Network represents a blockchain network, or Fabric channel. The Network can be used to access deployed smart
  # contracts, and to listen for events emitted when blocks are committed to the ledger.
  #
  # JChan & THowe believe this should be called a Channel, however Hyperledger Fabric has decided upon the terminology
  # network - https://github.com/hyperledger/fabric-gateway/issues/355#issuecomment-997888071
  #
  # TODO: original SDK has getChaincodeEvents and newChaincodeEventsRequest methods
  # https://github.com/hyperledger/fabric-gateway/blob/08118cf0a792898925d0b2710b0a9e7c5ec23228/node/src/network.ts
  # https://github.com/hyperledger/fabric-gateway/blob/main/pkg/client/network.go
  #
  class Network
    attr_reader :client, :signer, :name

    def initialize(client, signer, name)
      @client = client
      @signer = signer
      @name = name
    end
  end
end
