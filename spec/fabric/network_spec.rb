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

  describe '#client' do
    it 'returns the client from gateway' do
      expect(network.client).to eql(gateway.client)
    end
  end

  describe '#signer' do
    it 'returns the signer from gateway' do
      expect(network.signer).to eql(gateway.signer)
    end
  end

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
end
