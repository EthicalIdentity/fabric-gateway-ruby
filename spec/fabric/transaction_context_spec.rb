RSpec.describe Fabric::TransactionContext do
  describe '#new' do
    subject(:transaction_context) { described_class.new(signer) }

    let(:signer) { Fabric::Identity.new }
    let(:expected_attributes) do
      {
        nonce: transaction_context.nonce,
        creator: signer.serialize,
        transaction_id: transaction_context.transaction_id
      }
    end

    it { is_expected.to be_a(described_class) }

    it 'repeatedly has the same attributes' do
      expect(transaction_context).to have_attributes(expected_attributes)
      expect(transaction_context).to have_attributes(expected_attributes)
      expect(transaction_context).to have_attributes(expected_attributes)
    end
  end
end
