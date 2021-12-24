RSpec.describe Fabric::Contract do
  describe '#new' do
    context 'when contract_name is not passed' do
      subject(:contract) { described_class.new(client, signer, 'testnet', 'testchaincode') }

      let(:client) { build(:simple_client) }
      let(:signer) { Fabric::Identity.new }
      let(:expected_attributes) do
        {
          client: client,
          signer: signer,
          network_name: 'testnet',
          chaincode_name: 'testchaincode',
          contract_name: ''
        }
      end

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(expected_attributes) }
    end

    context 'when contract_name is passed' do
      subject(:contract) { described_class.new(client, signer, 'testnet', 'testchaincode', 'testcontract') }

      let(:client) { build(:simple_client) }
      let(:signer) { Fabric::Identity.new }
      let(:expected_attributes) do
        {
          client: client,
          signer: signer,
          network_name: 'testnet',
          chaincode_name: 'testchaincode',
          contract_name: 'testcontract'
        }
      end

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(expected_attributes) }
    end
  end

  describe '#evaluate' do
    pending 'TODO: implement'
  end

  describe '#evaluate_transaction' do
    pending 'TODO: implement'
  end

  describe '#submit' do
    pending 'TODO: implement'
  end

  describe '#submit_transaction' do
    pending 'TODO: implement'
  end
end
