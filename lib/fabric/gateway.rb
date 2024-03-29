# frozen_string_literal: true

module Fabric
  #
  # Gateway represents the connection of a specific client identity to a Fabric Gateway.
  #
  class Gateway
    attr_reader :signer, :client

    #
    # Initialize a new Gateway
    #
    # @param [Fabric::Identity] signer identity utilized to sign transactions
    # @param [Fabric::Client] client Gateway Client
    #
    def initialize(signer, client)
      raise InvalidArgument, 'signer must be Fabric::Identity' unless signer.is_a? Fabric::Identity
      raise InvalidArgument, 'client must be Fabric::Client' unless client.is_a? Fabric::Client

      @signer = signer
      @client = client
    end

    #
    # Initialize new network from the Gateway
    #
    # @param [string] name channel name
    #
    # @return [Fabric::Network] returns a new network
    #
    def new_network(name)
      Network.new(self, name)
    end
  end
end
