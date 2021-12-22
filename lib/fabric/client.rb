# frozen_string_literal: true

module Fabric
  #
  # Gateway Client, holds the raw grpcClient
  #
  class Client
    attr_reader :grpc_client

    #
    # Initializes a client
    #
    # @param [Gateway::Gateway::Stub] pass in a grpc client connection
    #
    # or alternatively
    # @param [string] host hostname and port of the gateway
    # @param [GRPC::Core::ChannelCredentials|GRPC::Core::XdsChannelCredentials|Symbol] channel credentials (usually the CA certificate)
    # @param [Hash] grpc client_opts
    #
    def initialize(*args)
      case args.size
      when 1
        init_stub args[0]
        return
      when 2
        init_grpc_args(args[0], args[1])
        return
      when 3
        init_grpc_args(args[0], args[1], **args[2])
        return
      end

      raise InvalidArgument, 'Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>'
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
