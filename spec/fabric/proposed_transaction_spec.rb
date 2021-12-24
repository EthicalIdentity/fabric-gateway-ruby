RSpec.describe Fabric::ProposedTransaction do
  describe '#new' do
    subject(:proposed_transaction) do
      described_class.new(client, signer, channel_name, chaincode_name, transaction_name)
    end

    let(:client) { build(:simple_client) }
    let(:signer) { build(:identity) }
    let(:channel_name) { 'test123' }
    let(:chaincode_name) { 'testchaincode' }
    let(:transaction_name) { 'testtransaction' }
    let(:expected_attributes) do
      {
        client: client,
        signer: signer,
        channel_name: channel_name,
        chaincode_name: chaincode_name,
        transaction_name: transaction_name
      }
    end

    it { is_expected.to be_a(described_class) }
    it { is_expected.to have_attributes(expected_attributes) }
    it { expect(proposal_builder.transaction_context).to be_a(Fabric::TransactionContext) }
  end
end
