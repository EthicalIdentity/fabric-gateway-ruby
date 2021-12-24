# frozen_string_literal: true

RSpec.describe Fabric::Client do
  describe 'Initialization' do
    context 'when invalid params are passed' do
      it {
        expect do
          described_class.new
        end.to raise_error(Fabric::InvalidArgument).with_message('Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>')
      }

      it {
        expect do
          described_class.new('invalid')
        end.to raise_error(Fabric::InvalidArgument).with_message('Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>')
      }

      it {
        expect do
          described_class.new('invalid',
                              'invalid2')
        end.to raise_error(Fabric::InvalidArgument).with_message('creds is not a ChannelCredentials, XdsChannelCredentials, or Symbol')
      }

      it { expect { described_class.new('invalid', 'invalid2', 'invalid3') }.to raise_error(TypeError) }

      it {
        expect do
          described_class.new('invalid', 'invalid2',
                              invalid: 'invalid3')
        end.to raise_error(Fabric::InvalidArgument).with_message('creds is not a ChannelCredentials, XdsChannelCredentials, or Symbol')
      }
    end

    context 'when gateway stub is passed' do
      it 'creates a client instance' do
        stub = Gateway::Gateway::Stub.new('localhost:5000', :this_channel_is_insecure)
        client = described_class.new(stub)
        expect(client.grpc_client).to eql(stub)
      end
    end

    context 'when params are passed' do
      context 'with simple args' do
        it 'creates a client instance passing params to Gateway::Gateway::Stub' do
          # not a big deal
          expectation = if RUBY_VERSION.start_with?('2.6')
                          ['localhost:1234', :this_channel_is_insecure,
                           {}]
                        else
                          ['localhost:1234', :this_channel_is_insecure]
                        end

          expect(Gateway::Gateway::Stub).to receive(:new).with(*expectation)

          described_class.new('localhost:1234', :this_channel_is_insecure)
        end
      end

      context 'with extended args' do
        it 'creates a client and passes all args to Gateway::Gateway::Stub' do
          creds = GRPC::Core::ChannelCredentials.new('')
          client_opts = {
            channel_args: {
              GRPC::Core::Channel::SSL_TARGET => 'peer0.org1.example.com'
            }
          }
          expect(Gateway::Gateway::Stub).to receive(:new).with('localhost:1234', creds, client_opts)
          described_class.new('localhost:1234', creds, client_opts)
        end
      end
    end
  end
end
