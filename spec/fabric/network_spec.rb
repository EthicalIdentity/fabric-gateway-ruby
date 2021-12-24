RSpec.describe Fabric::Network do
  describe '#new' do
    subject { described_class.new(client, signer, 'test123') }

    let(:client) { build(:simple_client) }
    let(:signer) { Fabric::Identity.new }
    let(:expected_attributes) do
      {
        client: client,
        signer: signer,
        name: 'test123'
      }
    end

    it { is_expected.to be_a(described_class) }
    it { is_expected.to have_attributes(expected_attributes) }
  end

  describe '#new_contract' do
    subject(:network) { described_class.new(client, signer, 'test123') }

    let(:client) { build(:simple_client) }
    let(:signer) { Fabric::Identity.new }

    context 'when contract_name is not passed' do
      let(:expected_attributes) do
        {
          client: client,
          signer: signer,
          network_name: 'test123',
          contract_name: '',
          chaincode_name: 'testchaincode'
        }
      end

      it { expect(network.new_contract('testchaincode')).to be_a(Fabric::Contract) }
      it { expect(network.new_contract('testchaincode')).to have_attributes(expected_attributes) }
    end

    context 'when contract_name is passed' do
      let(:expected_attributes) do
        {
          client: client,
          signer: signer,
          network_name: 'test123',
          chaincode_name: 'testchaincode',
          contract_name: 'testcontract'
        }
      end

      it { expect(network.new_contract('testchaincode', 'testcontract')).to be_a(Fabric::Contract) }
      it { expect(network.new_contract('testchaincode', 'testcontract')).to have_attributes(expected_attributes) }
    end
  end
end
