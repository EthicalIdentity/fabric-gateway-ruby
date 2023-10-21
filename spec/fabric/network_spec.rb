# frozen_string_literal: true

RSpec.describe Fabric::Network do
  subject(:network) { described_class.new(gateway, 'testnet') }

  let(:signer) { build(:identity, :user1) }
  let(:gateway) { build(:gateway, signer: signer) }

  describe '#new' do
    let(:expected_attributes) do
      {
        gateway: gateway,
        name: 'testnet'
      }
    end

    it { is_expected.to be_a(described_class) }
    it { is_expected.to have_attributes(expected_attributes) }
  end

  it_behaves_like 'a gateway accessor'

  describe '#new_contract' do
    context 'when contract_name is not passed' do
      let(:expected_attributes) do
        {
          network: network,
          client: gateway.client,
          gateway: gateway,
          signer: signer,
          network_name: 'testnet',
          contract_name: '',
          chaincode_name: 'testchaincode'
        }
      end

      it 'returns a contract' do
        expect(network.new_contract('testchaincode')).to be_a(Fabric::Contract)
      end

      it 'initializes the contract with the network' do
        expect(network.new_contract('testchaincode')).to have_attributes(expected_attributes)
      end
    end

    context 'when contract_name is passed' do
      let(:expected_attributes) do
        {
          network: network,
          client: gateway.client,
          gateway: gateway,
          signer: signer,
          network_name: 'testnet',
          chaincode_name: 'testchaincode',
          contract_name: 'testcontract'
        }
      end

      it 'returns a contract' do
        expect(network.new_contract('testchaincode', 'testcontract')).to be_a(Fabric::Contract)
      end

      it 'initializes the contract with the network' do
        expect(network.new_contract('testchaincode', 'testcontract')).to have_attributes(expected_attributes)
      end
    end
  end

  describe '#new_chaincode_events' do
    let(:contract) { build(:contract) }
    let(:spied_chaincode_events_request) { instance_double(ChaincodeEventsRequest) }

    before do
      allow(Fabric::ChaincodeEventsRequest).to receive(:new).and_return(spied_chaincode_events_request)
      allow(spied_chaincode_events_request).to receive(:get_events).and_return(nil)
    end

    context 'when start_block is not passed' do
      before do
        network.chaincode_events(contract)
      end

      it 'calls the ChaincodeEventsRequest constructor with the correct parameters' do
        expect(Fabric::ChaincodeEventsRequest).to have_received(:new).with(contract, start_block: nil)
      end
    end

    context 'when start_block is passed' do
      before do
        network.chaincode_events(contract, start_block: 123)
      end

      it 'calls the ChaincodeEventsRequest constructor with the correct parameters' do
        expect(Fabric::ChaincodeEventsRequest).to have_received(:new).with(contract, start_block: 123)
      end
    end

    context 'when call_options is not passed' do
      before do
        network.chaincode_events(contract)
      end

      it 'calls chaincode_events_request.get_events with the correct parameters' do
        expect(spied_chaincode_events_request).to have_received(:get_events).with({})
      end
    end

    context 'when call_options is passed' do
      before do
        network.chaincode_events(contract, call_options: { some_key: 'some_value' })
      end

      it 'calls chaincode_events_request.get_events with the correct parameters' do
        expect(spied_chaincode_events_request).to have_received(:get_events).with({ some_key: 'some_value' })
      end
    end

    context 'when block is not passed' do
      before do
        network.chaincode_events(contract)
      end

      it 'calls chaincode_events_request.get_events with the correct parameters' do # rubocop:disable RSpec/MultipleExpectations
        expect(spied_chaincode_events_request).to have_received(:get_events).with({}) do |&block|
          expect(block).to be_nil
        end
      end
    end

    context 'when block is passed' do
      let(:passed_block) { proc {} }

      before do
        network.chaincode_events(contract, &passed_block)
      end

      it 'calls chaincode_events_request.get_events with the correct parameters' do # rubocop:disable RSpec/MultipleExpectations
        expect(spied_chaincode_events_request).to have_received(:get_events).with({}) do |&block|
          expect(block).to eql(passed_block)
        end
      end
    end
  end

  describe '#new_chaincode_events_request' do
    let(:contract) { build(:contract) }

    context 'when start_block is not passed' do
      let(:returned_chaincode_events_request) { subject.new_chaincode_events_request(contract) }

      it 'returns a new ChaincodeEventsRequest' do
        expect(returned_chaincode_events_request).to be_a(Fabric::ChaincodeEventsRequest)
      end

      it 'returns a new ChaincodeEventsRequest with the correct attributes' do
        expect(returned_chaincode_events_request)
          .to have_attributes({
                                contract: contract,
                                start_block: nil
                              })
      end
    end

    context 'when start_block is passed' do
      let(:returned_chaincode_events_request) { subject.new_chaincode_events_request(contract, start_block: 155) }

      it 'returns a new ChaincodeEventsRequest' do
        expect(returned_chaincode_events_request).to be_a(Fabric::ChaincodeEventsRequest)
      end

      it 'returns a new ChaincodeEventsRequest with the correct attributes' do
        expect(returned_chaincode_events_request)
          .to have_attributes({
                                contract: contract,
                                start_block: 155
                              })
      end
    end
  end
end
