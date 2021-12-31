# frozen_string_literal: true

RSpec.describe Fabric::Contract do # rubocop:disable RSpec/FilePath
  subject(:contract) { described_class.new(network, 'testchaincode', 'testcontract') }

  let(:signer) { build(:identity, :user1) }
  let(:gateway) { build(:gateway, signer: signer) }
  let(:network) { build(:network, gateway: gateway) }

  # please refer to support/shared_context/client_mocks - it is where all the magic is happening!
  include_context 'client mocks'

  describe '#new' do
    context 'when contract_name is not passed' do
      subject(:contract) { described_class.new(network, 'testchaincode') }

      let(:expected_attributes) do
        {
          client: gateway.client,
          signer: signer,
          gateway: gateway,
          network: network,
          network_name: 'testnet',
          chaincode_name: 'testchaincode',
          contract_name: ''
        }
      end

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(expected_attributes) }
    end

    context 'when contract_name is passed' do
      subject(:contract) { described_class.new(network, 'testchaincode', 'testcontract') }

      let(:expected_attributes) do
        {
          client: gateway.client,
          signer: signer,
          gateway: gateway,
          network: network,
          network_name: 'testnet',
          chaincode_name: 'testchaincode',
          contract_name: 'testcontract'
        }
      end

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(expected_attributes) }
    end
  end

  describe '#client' do
    it 'returns the client from gateway' do
      expect(contract.client).to eql(gateway.client)
    end
  end

  describe '#signer' do
    it 'returns the signer from gateway' do
      expect(contract.signer).to eql(gateway.signer)
    end
  end

  describe '#gateway' do
    it 'returns the signer from gateway' do
      expect(contract.gateway).to eql(gateway)
    end
  end

  describe '#network_name' do
    it 'returns the network_name from the network' do
      expect(contract.network_name).to eql('testnet')
    end
  end

  describe '#evaluate' do
    context 'when no arguments are passed' do
      before do
        setup_evaluate_mock(gateway.client, :client_evaluate_response)
      end

      let!(:response) { contract.evaluate('test_transaction') }

      it 'calls client evaluate' do
        expect(gateway.client).to have_received(:evaluate)
      end

      it 'returns an evaluate response' do
        expect(response).to be(:client_evaluate_response)
      end

      it 'sends the expected transaction args' do
        expect(sent_chaincode_input_args).to eql(['testcontract:test_transaction'])
      end

      it 'sends no call options' do
        expect(sent_call_options).to eql({})
      end

      it 'sends no transient data' do
        expect(sent_chaincode_proposal_payload.TransientMap).to eq({})
      end

      it 'sends no endorsement organizations' do
        expect(sent_evaluate_request.target_organizations).to eql(%w[])
      end
    end

    context 'when arguments are passed' do
      before do
        setup_evaluate_mock(gateway.client, :client_evaluate_response)
      end

      let!(:response) do
        contract.evaluate('test_transaction',
                          arguments: %w[arg1 arg2],
                          transient_data: { something: 'different' },
                          endorsing_organizations: %w[org1 org2 org3])
      end

      it 'calls client evaluate' do
        expect(gateway.client).to have_received(:evaluate)
      end

      it 'returns an evaluate response' do
        expect(response).to be(:client_evaluate_response)
      end

      it 'sends the expected transaction args' do
        expect(sent_chaincode_input_args).to eql(%w[testcontract:test_transaction arg1 arg2])
      end

      it 'sends no call options' do
        expect(sent_call_options).to eql({})
      end

      it 'sends the expected transient data' do
        expect(sent_chaincode_proposal_payload.TransientMap).to eq({ 'something' => 'different' })
      end

      it 'sends the expected endorsement organizations' do
        expect(sent_evaluate_request.target_organizations).to eql(%w[org1 org2 org3])
      end
    end
  end

  describe '#evaluate_transaction' do
    context 'when no arguments are passed' do
      before do
        setup_evaluate_mock(gateway.client, :client_evaluate_response)
      end

      let!(:response) { contract.evaluate_transaction('test_transaction') }

      it 'calls client evaluate' do
        expect(gateway.client).to have_received(:evaluate)
      end

      it 'returns an evaluate response' do
        expect(response).to be(:client_evaluate_response)
      end

      it 'sends the expected transaction args' do
        expect(sent_chaincode_input_args).to eql(['testcontract:test_transaction'])
      end

      it 'sends no call options' do
        expect(sent_call_options).to eql({})
      end
    end

    context 'when arguments are passed' do
      before do
        setup_evaluate_mock(gateway.client, :client_evaluate_response)
      end

      let!(:response) { contract.evaluate_transaction('test_transaction', ['some arg']) }

      it 'calls client evaluate' do
        expect(gateway.client).to have_received(:evaluate)
      end

      it 'returns an evaluate response' do
        expect(response).to be(:client_evaluate_response)
      end

      it 'sends the expected transaction args' do
        expect(sent_chaincode_input_args).to eql(['testcontract:test_transaction', 'some arg'])
      end

      it 'sends no call options' do
        contract.evaluate_transaction('test_transaction', ['some arg'])

        expect(sent_call_options).to eql({})
      end
    end
  end

  describe '#submit' do
    pending 'TODO: implement'
  end

  describe '#submit_transaction' do
    pending 'TODO: implement'
  end

  describe '#new_proposal' do
    context 'when only transaction name is passed' do
      let(:proposal) { contract.new_proposal('some_transaction') }
      let(:proposed_transaction_expected_attributes) do
        [contract, 'testcontract:some_transaction',
         {
           arguments: [],
           transient_data: {},
           endorsing_organizations: []
         }]
      end

      it 'returns a proposal' do
        expect(proposal).to be_a(Fabric::Proposal)
      end

      it 'initializes a new ProposedTransaction with arguments' do
        allow(Fabric::ProposedTransaction).to receive(:new)
          .with(*proposed_transaction_expected_attributes)

        proposal

        expect(Fabric::ProposedTransaction).to have_received(:new)
      end
    end

    context 'when contract name is blank' do
      subject(:contract) { described_class.new(network, 'testchaincode') }

      let(:proposal) { contract.new_proposal('some_transaction') }
      let(:proposed_transaction_expected_attributes) do
        [contract, 'some_transaction',
         {
           arguments: [],
           transient_data: {},
           endorsing_organizations: []
         }]
      end

      it 'returns a proposal' do
        expect(proposal).to be_a(Fabric::Proposal)
      end

      it 'initializes a new ProposedTransaction with arguments' do
        allow(Fabric::ProposedTransaction).to receive(:new)
          .with(*proposed_transaction_expected_attributes)

        proposal

        expect(Fabric::ProposedTransaction).to have_received(:new)
      end
    end

    context 'when arguments, transient_data, and endorsing_organizations are passed' do
      let(:proposal) do
        contract.new_proposal('some_transaction',
                              arguments: %w[two arguments],
                              transient_data: { transient_data: 'value' },
                              endorsing_organizations: %w[org1 org2])
      end
      let(:proposed_transaction_expected_attributes) do
        [contract, 'testcontract:some_transaction',
         {
           arguments: %w[two arguments],
           transient_data: { transient_data: 'value' },
           endorsing_organizations: %w[org1 org2]
         }]
      end

      it 'returns a proposal' do
        expect(proposal).to be_a(Fabric::Proposal)
      end

      it 'initializes a new ProposedTransaction with arguments' do
        allow(Fabric::ProposedTransaction).to receive(:new)
          .with(*proposed_transaction_expected_attributes)

        proposal

        expect(Fabric::ProposedTransaction).to have_received(:new)
      end
    end
  end

  describe '#qualified_transaction_name' do
    context 'when contract_name is nil' do
      subject(:contract) { described_class.new(network, 'testchaincode', nil) }

      it 'returns only the transaction name' do
        expect(contract.qualified_transaction_name('some_transaction')).to eql('some_transaction')
      end
    end

    context 'when contract_name is empty' do
      subject(:contract) { described_class.new(network, 'testchaincode') }

      it 'returns only the transaction name' do
        expect(contract.qualified_transaction_name('some_transaction')).to eql('some_transaction')
      end
    end

    context 'when contract_name is set' do
      subject(:contract) { described_class.new(network, 'testchaincode', 'test_contract') }

      it 'prepends the contract name to the transaction name' do
        expect(contract.qualified_transaction_name('some_transaction')).to eql('test_contract:some_transaction')
      end
    end
  end
end
