# frozen_string_literal: true

module Fabric
  #
  # Gateway Client represents the connection to a Hyperledger Fabric Gateway.
  #
  class Client
    attr_reader :grpc_client

    #
    # Initializes a client
    #
    # @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:initialize
    #
    # @param [Gateway::Gateway::Stub] grpc_client grpc gateway client stub
    # @param [string] host hostname and port of the gateway
    # @param [GRPC::Core::ChannelCredentials|GRPC::Core::XdsChannelCredentials|Symbol] creds channel credentials (usually the CA certificate)
    # @param [<Type>] **client_opts <description>
    #
    def initialize(grpc_client: nil, host: nil, creds: nil, **client_opts)
      if grpc_client
        init_stub grpc_client
      elsif host && creds
        init_grpc_args(host, creds, **client_opts)
      else
        raise InvalidArgument, 'Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>'
      end
    end

    private

    def init_stub(stub)
      unless stub.is_a? ::Gateway::Gateway::Stub
        raise InvalidArgument, 'Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>'
      end

      @grpc_client = stub
    end

    def init_grpc_args(host, creds, **client_opts)
      unless creds.is_a?(GRPC::Core::ChannelCredentials) ||
             creds.is_a?(GRPC::Core::XdsChannelCredentials) ||
             creds.is_a?(Symbol)
        raise InvalidArgument, 'creds is not a ChannelCredentials, XdsChannelCredentials, or Symbol'
      end

      @grpc_client = ::Gateway::Gateway::Stub.new(host, creds, **client_opts)
    end
  end
end
