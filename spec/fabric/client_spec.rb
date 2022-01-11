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
      let(:expected_message) do
        if RUBY_VERSION.start_with?('2.6')
          'unknown keyword: bad_arg'
        else
          'unknown keyword: :bad_arg'
        end
      end

      it 'raises an error' do
        expect { described_class.new(host: 'localhost:5000', creds: :this_channel_is_insecure, bad_arg: 'wrong') }
          .to raise_error(ArgumentError)
          .with_message(expected_message)
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
      subject(:client) { described_class.new(host: 'localhost:1234', creds: creds, **client_opts) }

      let(:creds) { GRPC::Core::ChannelCredentials.new('') }
      let(:client_opts) do
        {
          channel_args: {
            GRPC::Core::Channel::SSL_TARGET => 'peer0.org1.example.com'
          }
        }
      end

      it 'instantiates a Gateway::Gateway::Stub' do
        expect(client.grpc_client).to be_a(Gateway::Gateway::Stub)
      end

      it 'honors client_opts' do
        expect(client.grpc_client.instance_variable_get(:@host)).to eql('peer0.org1.example.com')
      end
    end

    context 'when default_call_options are passed' do
      let(:default_call_options) do
        {
          endorse_options: { deadline: 5 },
          evaluate_options: { deadline: 10 },
          submit_options: { deadline: 15 },
          commit_status_options: { deadline: 20 },
          chaincode_events_options: { deadline: 25 }
        }
      end

      it 'sets default_call_options' do
        stub = Gateway::Gateway::Stub.new('localhost:5000', :this_channel_is_insecure)
        client = described_class.new(grpc_client: stub, default_call_options: default_call_options)
        expect(client.default_call_options).to eql(default_call_options)
      end
    end

    context 'when default_call_options are not passed' do
      let(:default_call_options) do
        {
          endorse_options: {},
          evaluate_options: {},
          submit_options: {},
          commit_status_options: {},
          chaincode_events_options: {}
        }
      end

      it 'uses empty default_call_options' do
        stub = Gateway::Gateway::Stub.new('localhost:5000', :this_channel_is_insecure)
        client = described_class.new(grpc_client: stub)
        expect(client.default_call_options).to eql(default_call_options)
      end
    end
  end

  # All the client tests are just mock tests. Must consider writing integration tests
  # for all the Fabric Gateway operations - endorse, evaluate, submit, commit_status,
  # and chaincode_events.

  describe '#evaluate' do
    subject(:client) { build(:simple_client) }

    before do
      allow(client.grpc_client).to receive(:evaluate)
    end

    context 'when options are not passed' do
      it 'calls evaluate on the grpc_client' do
        client.evaluate('evaluate_request')
        expect(client.grpc_client).to have_received(:evaluate).with('evaluate_request', {})
      end
    end

    context 'when options are passed' do
      it 'calls evaluate on the grpc_client' do
        client.evaluate('evaluate_request', { deadline: 5 })
        expect(client.grpc_client).to have_received(:evaluate).with('evaluate_request', { deadline: 5 })
      end
    end
  end

  describe '#endorse' do
    subject(:client) { build(:simple_client) }

    before do
      allow(client.grpc_client).to receive(:endorse)
    end

    context 'when options are not passed' do
      it 'calls endorse on the grpc_client' do
        client.endorse('endorse_request')
        expect(client.grpc_client).to have_received(:endorse).with('endorse_request', {})
      end
    end

    context 'when options are passed' do
      it 'calls endorse on the grpc_client' do
        client.endorse('endorse_request', { deadline: 5 })
        expect(client.grpc_client).to have_received(:endorse).with('endorse_request', { deadline: 5 })
      end
    end
  end

  describe '#submit' do
    subject(:client) { build(:simple_client) }

    before do
      allow(client.grpc_client).to receive(:submit)
    end

    context 'when options are not passed' do
      it 'calls submit on the grpc_client' do
        client.submit('submit_request')
        expect(client.grpc_client).to have_received(:submit).with('submit_request', {})
      end
    end

    context 'when options are passed' do
      it 'calls submit on the grpc_client' do
        client.submit('submit_request', { deadline: 5 })
        expect(client.grpc_client).to have_received(:submit).with('submit_request', { deadline: 5 })
      end
    end
  end

  describe '#commit_status' do
    subject(:client) { build(:simple_client) }

    before do
      allow(client.grpc_client).to receive(:commit_status)
    end

    context 'when options are not passed' do
      it 'calls commit_status on the grpc_client' do
        client.commit_status('commit_status_request')
        expect(client.grpc_client).to have_received(:commit_status).with('commit_status_request', {})
      end
    end

    context 'when options are passed' do
      it 'calls commit_status on the grpc_client' do
        client.commit_status('commit_status_request', { deadline: 5 })
        expect(client.grpc_client).to have_received(:commit_status).with('commit_status_request', { deadline: 5 })
      end
    end
  end

  describe '#chaincode_events' do
    subject(:client) { build(:simple_client) }

    before do
      allow(client.grpc_client).to receive(:chaincode_events)
    end

    context 'when options and block are not passed' do
      it 'calls chaincode_events on the grpc_client' do # rubocop:disable RSpec/MultipleExpectations
        client.chaincode_events('chaincode_events_request')
        expect(client.grpc_client).to have_received(:chaincode_events).with('chaincode_events_request', {}) do |&block|
          expect(block).to be_nil
        end
      end
    end

    context 'when options are passed' do
      it 'calls chaincode_events on the grpc_client' do
        client.chaincode_events('chaincode_events_request', { deadline: 5 })
        expect(client.grpc_client).to have_received(:chaincode_events).with('chaincode_events_request',
                                                                            { deadline: 5 })
      end
    end

    context 'when block is passed' do
      let(:passed_block) { proc {} }

      it 'passes the block to the grpc_client' do # rubocop:disable RSpec/MultipleExpectations
        client.chaincode_events('chaincode_events_request', &passed_block)
        expect(client.grpc_client).to have_received(:chaincode_events).with('chaincode_events_request', {}) do |&block|
          expect(block).to eql(passed_block)
        end
      end
    end
  end
end
