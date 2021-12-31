# frozen_string_literal: true

RSpec.describe Fabric::Status do # rubocop:disable RSpec/FilePath
  describe '::TRANSACTION_STATUSES' do
    let(:expected_transaction_values) do
      { BAD_RESPONSE_PAYLOAD: 21, BAD_RWSET: 22, ILLEGAL_WRITESET: 23, INVALID_WRITESET: 24, INVALID_CHAINCODE: 25,
        NOT_VALIDATED: 254, INVALID_OTHER_REASON: 255, VALID: 0, NIL_ENVELOPE: 1, BAD_PAYLOAD: 2, BAD_COMMON_HEADER: 3,
        BAD_CREATOR_SIGNATURE: 4, INVALID_ENDORSER_TRANSACTION: 5, INVALID_CONFIG_TRANSACTION: 6,
        UNSUPPORTED_TX_PAYLOAD: 7, BAD_PROPOSAL_TXID: 8, DUPLICATE_TXID: 9, ENDORSEMENT_POLICY_FAILURE: 10,
        MVCC_READ_CONFLICT: 11, PHANTOM_READ_CONFLICT: 12, UNKNOWN_TX_TYPE: 13, TARGET_CHAIN_NOT_FOUND: 14,
        MARSHAL_TX_ERROR: 15, NIL_TXACTION: 16, EXPIRED_CHAINCODE: 17, CHAINCODE_VERSION_CONFLICT: 18,
        BAD_HEADER_EXTENSION: 19, BAD_CHANNEL_HEADER: 20 }
    end

    it 'returns a hash of transaction statuses' do
      expect(Fabric::Status::TRANSACTION_STATUSES).to be_a(Hash)
    end

    it 'returns proper transaction statuses' do
      expect(Fabric::Status::TRANSACTION_STATUSES).to eql(expected_transaction_values)
    end
  end

  describe '#initialize' do
    context 'when code is VALID' do
      subject(:status) { described_class.new('abc123', 123, 0) }

      let(:expected_attributes) do
        {
          block_number: 123,
          transaction_id: 'abc123',
          code: 0,
          successful: true
        }
      end

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(expected_attributes) }
    end

    context 'when code is not VALID' do
      subject(:status) { described_class.new('abc123', 123, 1) }

      let(:expected_attributes) do
        {
          block_number: 123,
          transaction_id: 'abc123',
          code: 1,
          successful: false
        }
      end

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(expected_attributes) }
    end
  end
end
