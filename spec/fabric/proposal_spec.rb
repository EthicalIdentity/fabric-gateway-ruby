RSpec.describe Fabric::Proposal do
  describe '#new' do
    subject(:proposal) { described_class.new(client, signer, 'testnet', 'testchaincode') }

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
end
