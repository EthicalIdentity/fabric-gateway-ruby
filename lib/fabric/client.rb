module Fabric
  #
  # Gateway Client, holds the raw grpcClient
  #
  class Client
    #
    # Initializes a client
    #
    # @param [Gateway::Gateway::Stub] pass in a grpc client connection
    # 
    # or alternatively
    # @param [string] grpc uri
    # @param [GRPC::Core::ChannelCredentials|GRPC::Core::XdsChannelCredentials|Symbol] channel credentials (usually the CA certificate)
    # @param [Hash] grpc client_opts
    #

    attr_accessor :grpc_client
    def initialize(*args)
      case args.size
      when 1
        init_stub args[0]
        return
      when 2, 3
        init_grpc_args
        return
      end

      raise InvalidArgument.new('Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>')
    end

    private

    def init_stub stub
      unless stub.is_a? Gateway::Gateway::Stub
      raise InvalidArgument.new('Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>')
      @grpc_client = stub
    end

    def init_grpc_args(host, creds, **client_opts)
      unless args[1].is_a?(GRPC::Core::ChannelCredentials) ||
        args[1].is_a?(GRPC::Core::XdsChannelCredentials) || 
        args[1].is_a?(Symbol)
          raise InvalidArgument.new('creds is not a ChannelCredentials, XdsChannelCredentials, or Symbol')
      end

      @grpc_client = Gateway::Gateway::Stub.new(host, creds, **client_opts)
    end
  end
end