# frozen_string_literal: true

module Fabric
  #
  # Gateway Client represents the connection to a Hyperledger Fabric Gateway.
  #
  class Client
    attr_reader :grpc_client, :default_call_options

    #
    # Initializes a client
    #
    #
    # @overload initialize(grpc_client: client, default_call_options: {}, **client_opts)
    #   Initializes a client from a gRPC Gateway client stub
    #   @param [Gateway::Gateway::Stub] grpc_client grpc gateway client stub
    #   @param [Hash] default_call_options call options to use by default for different operations
    #   @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response Keyword Argument call options for
    #     *_options default_call_options
    #   @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:initialize Keyword arguments for **client_opts
    #   @option default_call_options [Hash] :endorse_options default options for endorse call
    #   @option default_call_options [Hash] :evaluate_options default options for evaluate call
    #   @option default_call_options [Hash] :submit_options default options for submit call
    #   @option default_call_options [Hash] :commit_status_options default options for commit_status call
    #   @option default_call_options [Hash] :chaincode_events_options default options for chaincode_events call
    #   @param [Hash] **client_opts client initialization options
    # @overload initialize(host: host, creds: creds, default_call_options: {}, **client_opts)
    #   Instantiates a new gRPC Gateway client stub from the parameters
    #   @param [string] host hostname and port of the gateway
    #   @param [GRPC::Core::ChannelCredentials|GRPC::Core::XdsChannelCredentials|Symbol] creds channel credentials
    #     (usually the CA certificate)
    #   @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response Keyword Argument call options for
    #     *_options default_call_options
    #   @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:initialize Keyword arguments for **client_opts
    #   @option default_call_options [Hash] :endorse_options default options for endorse call
    #   @option default_call_options [Hash] :evaluate_options default options for evaluate call
    #   @option default_call_options [Hash] :submit_options default options for submit call
    #   @option default_call_options [Hash] :commit_status_options default options for commit_status call
    #   @option default_call_options [Hash] :chaincode_events_options default options for chaincode_events call
    #   @param [Hash] **client_opts client initialization options
    #
    def initialize(grpc_client: nil, host: nil, creds: nil, default_call_options: {}, **client_opts)
      if grpc_client
        init_stub grpc_client
      elsif host && creds
        init_grpc_args(host, creds, **client_opts)
      else
        raise InvalidArgument, 'Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>'
      end
      init_call_options(default_call_options)
    end

    #
    # Submits an evaluate_request to the gateway to be evaluted.
    #
    # @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response Call options for options parameter
    # @param [Gateway::EvaluateRequest] evaluate_request
    # @param [Hash] options gRPC call options (merged with default_call_options from initializer)
    #
    # @return [Gateway::EvaluateResponse] evaluate_response
    #
    def evaluate(evaluate_request, options = {})
      @grpc_client.evaluate(evaluate_request, final_call_options(:evaluate, options))
    end

    #
    # Submits an endorse_request to the gateway to be evaluted.
    #
    # @param [Gateway::EndorseRequest] endorse_request
    # @param [Hash] options gRPC call options (merged with default options) @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @return [Gateway::EndorseResponse] endorse_response
    #
    def endorse(endorse_request, options = {})
      @grpc_client.endorse(endorse_request, final_call_options(:endorse, options))
    end

    #
    # Submits an submit_request to the gateway to be evaluted.
    #
    # @param [Gateway::SubmitRequest] submit_request
    # @param [Hash] options gRPC call options (merged with default options) @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @return [Gateway::SubmitResponse] submit_response
    #
    def submit(submit_request, options = {})
      @grpc_client.submit(submit_request, final_call_options(:submit, options))
    end

    #
    # Submits an commit_status_request to the gateway to be evaluted.
    #
    # @param [Gateway::CommitStatusRequest] commit_status_request
    # @param [Hash] options gRPC call options (merged with default options) @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # Returns an enum or if you pass a block, use the block.
    # @return [Gateway::CommitStatusResponse] commit_status_response
    #
    def commit_status(commit_status_request, options = {})
      @grpc_client.commit_status(commit_status_request, final_call_options(:commit_status, options))
    end

    #
    # Subscribe to chaincode events
    #
    # @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:server_streamer GRPC::ClientStub#server_streamer
    #   - gRPC Underlying Call Reference
    #
    #
    # @overload chaincode_events(chaincode_events_request)
    #   @example Utilizing Blocking Enumerator
    #     call = client.chaincode_events(chaincode_events_request)
    #     call.each do |event|
    #       pp event
    #     end
    #   @param [Gateway::ChaincodeEventsRequest] chaincode_events_request
    #   @param [Hash] options gRPC call options (merged with default options)
    #   @return [Enumerator] enumerator with Gateway::ChaincodeEventsResponse objects
    # @overload chaincode_events(chaincode_events_request)
    #   @example Utilizing a blocking block
    #     client.chaincode_events(chaincode_events_request) do |event|
    #       pp event
    #     end
    #   @param [Gateway::ChaincodeEventsRequest] chaincode_events_request
    #   @param [Hash] options gRPC call options (merged with default options)
    #   @yield [event] Blocking call that yields Gateway::ChaincodeEventsResponse objects when received from the server
    #   @yieldparam event [Gateway::ChaincodeEventsResponse] chaincode event
    #   @return [nil]
    # @overload chaincode_events(chaincode_events_request, {return_op: true})
    #   @example Utilizing an operation control object and a enumerator
    #     op = client.chaincode_events(chaincode_events_request, {return_op: true})
    #
    #     t = Thread.new do
    #       call = op.execute
    #       call.each do |event|
    #         pp event
    #       end
    #     end
    #
    #     op.status
    #     op.cancelled?
    #     op.cancel
    #   @param [Gateway::ChaincodeEventsRequest] chaincode_events_request
    #   @param [Hash] options gRPC call options (merged with default options)
    #   @return [GRPC::ActiveCall::Operation]
    # @overload chaincode_events(chaincode_events_request, {return_op: true})
    #   @example Utilizing an operation control object and a block
    #     op = client.chaincode_events(chaincode_events_request, {return_op: true}) do |event|
    #       pp event
    #     end
    #
    #     t = Thread.new do
    #       call = op.execute
    #     end
    #
    #     op.status
    #     op.cancelled?
    #     op.cancel
    #   @param [Gateway::ChaincodeEventsRequest] chaincode_events_request
    #   @param [Hash] options gRPC call options (merged with default options)
    #   @yield [event] Blocking call that yields Gateway::ChaincodeEventsResponse objects when received from the server
    #   @yieldparam event [Gateway::ChaincodeEventsResponse] chaincode event
    #   @return [GRPC::ActiveCall::Operation]
    #
    def chaincode_events(chaincode_events_request, options = {}, &block)
      @grpc_client.chaincode_events(chaincode_events_request,
                                    final_call_options(:chaincode_events, options), &block)
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

    def init_call_options(call_options)
      @default_call_options = call_options
      @default_call_options[:endorse_options] ||= {}
      @default_call_options[:evaluate_options] ||= {}
      @default_call_options[:submit_options] ||= {}
      @default_call_options[:commit_status_options] ||= {}
      @default_call_options[:chaincode_events_options] ||= {}
    end

    def final_call_options(call_type, call_options)
      options = @default_call_options["#{call_type}_options".to_sym].merge(call_options || {})
      if (deadline = options[:deadline]) && !(deadline.is_a? Time)
        options[:deadline] = GRPC::Core::TimeConsts.from_relative_time(deadline)
      end
      options
    end
  end
end
