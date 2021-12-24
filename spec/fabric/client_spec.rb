# frozen_string_literal: true

RSpec.describe Fabric::Client do
  describe 'Initialization' do
    context 'when no params are passed' do
      it 'raises an error' do
        expect { described_class.new }.to raise_error(Fabric::InvalidArgument)
          .with_message('Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>')
      end
    end

    context 'when passing invalid grpc client' do
      it 'raises an error' do
        expect { described_class.new(grpc_client: 'invalid') }.to raise_error(Fabric::InvalidArgument)
          .with_message('Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>')
      end
    end

    context 'when passing invalid grpc args' do
      it 'raises an error' do
        expect { described_class.new(host: 'invalid', creds: 'invalid2') }.to raise_error(Fabric::InvalidArgument)
          .with_message('creds is not a ChannelCredentials, XdsChannelCredentials, or Symbol')
      end
    end

    context 'when passing invalid client_opts' do
      it 'raises an error' do
        expect { described_class.new(host: 'localhost:5000', creds: :this_channel_is_insecure, bad_arg: 'wrong') }
          .to raise_error(ArgumentError)
          .with_message('unknown keyword: :bad_arg')
      end
    end

    context 'when grpc_client is passed' do
      it 'creates a client instance' do
        stub = Gateway::Gateway::Stub.new('localhost:5000', :this_channel_is_insecure)
        client = described_class.new(grpc_client: stub)
        expect(client.grpc_client).to eql(stub)
      end
    end

    context 'when grpc_client host and creds are passed' do
      let(:expected_args) do
        if RUBY_VERSION.start_with?('2.6')
          ['localhost:1234', :this_channel_is_insecure, {}]
        else
          ['localhost:1234', :this_channel_is_insecure]
        end
      end

      before do
        allow(Gateway::Gateway::Stub).to receive(:new)
      end

      it 'creates a client instance passing params to Gateway::Gateway::Stub' do
        described_class.new(host: 'localhost:1234', creds: :this_channel_is_insecure)
        expect(Gateway::Gateway::Stub).to have_received(:new).with(*expected_args)
      end
    end

    context 'when grpc_client host, creds, and client_opts are passed' do
      let(:creds) { GRPC::Core::ChannelCredentials.new('') }
      let(:client_opts) do
        {
          channel_args: {
            GRPC::Core::Channel::SSL_TARGET => 'peer0.org1.example.com'
          }
        }
      end
      subject(:client) { described_class.new(host: 'localhost:1234', creds: creds, **client_opts) }
      it 'instantiates a Gateway::Gateway::Stub' do
        expect(client.grpc_client).to be_a(Gateway::Gateway::Stub)
      end

      it 'honors client_opts' do
        expect(client.grpc_client.instance_variable_get(:@host)).to eql('peer0.org1.example.com')
      end
    end
  end
end
