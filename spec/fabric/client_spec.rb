RSpec.describe Fabric::Client do
  describe 'Initialization' do
    context 'when invalid params are passed' do
      it { expect { Fabric::Client.new }.to raise_error(Fabric::InvalidArgument).with_message('Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>') }
      it { expect { Fabric::Client.new("invalid") }.to raise_error(Fabric::InvalidArgument).with_message('Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>') }
      it { expect { Fabric::Client.new("invalid", "invalid2") }.to raise_error(Fabric::InvalidArgument).with_message('creds is not a ChannelCredentials, XdsChannelCredentials, or Symbol') }
      it { expect { Fabric::Client.new("invalid", "invalid2", "invalid3") }.to raise_error(TypeError) }
      it { expect { Fabric::Client.new("invalid", "invalid2", invalid:"invalid3") }.to raise_error(Fabric::InvalidArgument).with_message('creds is not a ChannelCredentials, XdsChannelCredentials, or Symbol') }
    end

    context 'when gateway stub is passed' do
      it 'creates a client instance' do
        stub = Gateway::Gateway::Stub.new("localhost:5000", :this_channel_is_insecure)
        client=Fabric::Client.new(stub)
        expect(client.grpc_client).to eql(stub)
      end
    end

    context 'when params are passed' do
      context 'simple args' do
        it 'creates a client instance passing params to Gateway::Gateway::Stub' do
          expect(Gateway::Gateway::Stub).to receive(:new).with("localhost:1234", :this_channel_is_insecure)
          client=Fabric::Client.new("localhost:1234", :this_channel_is_insecure)
        end
      end
      
      context 'extended args' do
        it 'creates a client and passes all args to Gateway::Gateway::Stub' do
          creds = GRPC::Core::ChannelCredentials.new('')
          client_opts = {
            channel_args: {
              GRPC::Core::Channel::SSL_TARGET => 'peer0.org1.example.com'
            }
          }
          expect(Gateway::Gateway::Stub).to receive(:new).with("localhost:1234", creds, client_opts)
          client=Fabric::Client.new("localhost:1234", creds, client_opts)
        end
      end
    end
  end
end