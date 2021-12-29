# frozen_string_literal: true

RSpec.describe Fabric::ProposedTransaction do
  subject(:proposed_transaction) do
    described_class.new(contract, 'testTransaction', **extra_args)
  end

  before do
    # freeze time and the nonce to make the test deterministic
    allow(contract.signer.crypto_suite).to receive(:generate_nonce).and_return('static')
    Timecop.freeze(Time.utc(2021, 12, 25, 12, 0, 0))
  end

  after do
    Timecop.unfreeze
  end

  let(:contract) { build(:contract) }
  let(:extra_args) { {} }

  describe '#new' do
    context 'when only required arguments are passed' do
      let(:expected_attributes) do
        {
          contract: contract,
          transaction_name: 'testTransaction',
          transient_data: {},
          arguments: [],
          endorsing_organizations: []
        }
      end

      let(:expected_proposed_transaction_json) do
        <<~HEREDOC.delete("\n")
          {"transactionId":"f4ba2e876e3e6bc1b1b4a1f11b6f5f1ef9f80228bdadeb2f6c4a8a365ad8830e","proposal":
          {"proposalBytes":"Cn8KaAgDGgYIwI+cjgYiB3Rlc3RuZXQqQGY0YmEyZTg3NmUzZTZiYzFiMWI0YTFmMTFiNmY1ZjFlZ
          jlmODAyMjhiZGFkZWIyZjZjNGE4YTM2NWFkODgzMGU6ERIPEg10ZXN0Y2hhaW5jb2RlEhMKCQoHT3JnMU1TUBIGc3RhdGlj
          EioKKAomCAISDxINdGVzdGNoYWluY29kZRoRCg90ZXN0VHJhbnNhY3Rpb24="}}
        HEREDOC
      end

      it { is_expected.to be_a(described_class) }

      it 'maps the parameters to instance attributes' do
        expect(proposed_transaction).to have_attributes(expected_attributes)
      end

      it 'produces a proposed_transaction' do
        expect(proposed_transaction.proposed_transaction).to be_a(::Gateway::ProposedTransaction)
      end

      it 'produces a valid proposed_transaction' do
        expect(proposed_transaction.proposed_transaction.to_json).to eq(expected_proposed_transaction_json)
      end
    end

    context 'when extra arguments are passed' do
      let(:extra_args) do
        {
          arguments: %w[arg1 arg2],
          transient_data: { transient_data_key: 'transient_data_value' },
          endorsing_organizations: %w[org1 org2]
        }
      end

      let(:expected_attributes) do
        {
          contract: contract,
          transaction_name: 'testTransaction',
          transient_data: { transient_data_key: 'transient_data_value' },
          arguments: %w[arg1 arg2],
          endorsing_organizations: %w[org1 org2]
        }
      end

      let(:expected_proposed_transaction_json) do
        <<~HEREDOC.delete("\n")
          {"transactionId":"f4ba2e876e3e6bc1b1b4a1f11b6f5f1ef9f80228bdadeb2f6c4a8a365ad8830e","proposal":
          {"proposalBytes":"Cn8KaAgDGgYIwI+cjgYiB3Rlc3RuZXQqQGY0YmEyZTg3NmUzZTZiYzFiMWI0YTFmMTFiNmY1ZjFlZ
          jlmODAyMjhiZGFkZWIyZjZjNGE4YTM2NWFkODgzMGU6ERIPEg10ZXN0Y2hhaW5jb2RlEhMKCQoHT3JnMU1TUBIGc3RhdGlj
          EmIKNAoyCAISDxINdGVzdGNoYWluY29kZRodCg90ZXN0VHJhbnNhY3Rpb24KBGFyZzEKBGFyZzISKgoSdHJhbnNpZW50X2R
          hdGFfa2V5EhR0cmFuc2llbnRfZGF0YV92YWx1ZQ=="},"endorsingOrganizations":["org1","org2"]}
        HEREDOC
      end

      it 'maps the parameters to instance attributes' do
        expect(proposed_transaction).to have_attributes(expected_attributes)
      end

      it 'produces a valid proposed_transaction' do
        expect(proposed_transaction.proposed_transaction.to_json).to eq(expected_proposed_transaction_json)
      end
    end
  end

  describe '#network' do
    it 'returns the network of the contract' do
      expect(proposed_transaction.network).to eql(contract.network)
    end
  end

  describe '#client' do
    it 'returns the client from gateway' do
      expect(proposed_transaction.client).to eql(contract.client)
    end
  end

  describe '#signer' do
    it 'returns the signer from gateway' do
      expect(proposed_transaction.signer).to eql(contract.signer)
    end
  end

  describe '#gateway' do
    it 'returns the signer from gateway' do
      expect(proposed_transaction.gateway).to eql(contract.gateway)
    end
  end

  describe '#network_name' do
    it 'returns the network_name from the network' do
      expect(contract.network_name).to eql('testnet')
    end
  end

  describe '#contract_name' do
    it 'returns the contract_name from the contract' do
      expect(contract.contract_name).to eql('testcontract')
    end
  end

  describe '#chaincode_name' do
    it 'returns the chaincode_name from the contract' do
      expect(contract.chaincode_name).to eql('testchaincode')
    end
  end

  describe '#generate_proposed_transaction' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    # consider testing this individually in the future
    it 'is already tested', skip: 'Tested in #new' do
      skip
    end
  end

  describe '#signed_proposal' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    # consider testing this individually in the future
    it 'is already tested', skip: 'Tested in #new' do
      skip
    end
  end

  describe '#proposal' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    it 'is already tested', skip: 'Tested in #new' do
      skip
    end
  end

  describe '#header' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    it 'is already tested', skip: 'Tested in #new' do
      skip
    end
  end

  describe '#channel_header' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    it 'is already tested', skip: 'Tested in #new' do
      skip
    end
  end

  describe '#channel_header_extension' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    it 'is already tested', skip: 'Tested in #new' do
      skip
    end
  end

  describe '#chaincode_id' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    it 'is already tested', skip: 'Tested in #new' do
      skip
    end
  end

  describe '#chaincode_proposal_payload' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    it 'is already tested', skip: 'Tested in #new' do
      skip
    end
  end

  describe '#timestamp' do # rubocop:disable RSpec/RepeatedExampleGroupBody
    it 'is already tested', skip: 'Tested in #new' do
      skip
    end
  end

  describe '#nonce' do
    before do
      allow(contract.signer.crypto_suite).to receive(:generate_nonce).and_call_original
    end

    it 'utilizes nonce from the crypto_suite' do
      proposed_transaction.nonce

      expect(contract.signer.crypto_suite).to have_received(:generate_nonce)
    end

    context 'when called more than once' do
      it 'returns the same nonce' do
        expect(proposed_transaction.nonce).to eql(proposed_transaction.nonce)
          .and eql(proposed_transaction.nonce)
          .and eql(proposed_transaction.nonce)
      end
    end
  end

  describe '#transaction_id' do
    context 'when called once' do
      before do
        allow(contract.signer.crypto_suite).to receive(:generate_nonce).and_return('static')
      end

      let(:expected_transaction_id) { 'f4ba2e876e3e6bc1b1b4a1f11b6f5f1ef9f80228bdadeb2f6c4a8a365ad8830e' }

      it 'generates a nonce' do
        proposed_transaction.transaction_id
        expect(contract.signer.crypto_suite).to have_received(:generate_nonce)
      end

      it 'generates a transaction id' do
        expect(proposed_transaction.transaction_id).to eql(expected_transaction_id)
      end
    end

    context 'when called more than once' do
      it 'returns the same transaction id' do
        expect(proposed_transaction.transaction_id).to eql(proposed_transaction.transaction_id)
          .and eql(proposed_transaction.transaction_id)
          .and eql(proposed_transaction.transaction_id)
      end
    end
  end

  describe '#signature_header' do
    let(:expected_signature_header_json) { '{"creator":"CgdPcmcxTVNQ","nonce":"c3RhdGlj"}' }

    it 'returns a signature header' do
      expect(proposed_transaction.signature_header).to be_a(Common::SignatureHeader)
    end

    it 'returns a signature header with the correct values' do
      expect(proposed_transaction.signature_header.to_json).to eql(expected_signature_header_json)
    end
  end

  describe '#as_proto' do
    it 'returns a protobuf Gateway::ProposedTransaction' do
      expect(proposed_transaction.as_proto).to be_a(Gateway::ProposedTransaction)
    end
  end

  describe '#to_proto' do
    let(:expected_proposed_transaction) do
      "\n" \
        "@f4ba2e876e3e6bc1b1b4a1f11b6f5f1ef9f80228bdadeb2f6c4a8a365ad8830e\x12\xB0\x01\n" \
        "\xAD\x01\n" \
        "\x7F\n" \
        "h\b\x03\x1A\x06\b\xC0\x8F\x9C\x8E\x06\"\atestnet*@f4ba2e876e3e6bc1b1b4a1f11b6f5f1ef" \
        "9f80228bdadeb2f6c4a8a365ad8830e:\x11\x12\x0F\x12\rtestchaincode\x12\x13\n" \
        "\t\n" \
        "\aOrg1MSP\x12\x06static\x12*\n" \
        "(\n" \
        "&\b\x02\x12\x0F\x12\rtestchaincode\x1A\x11\n" \
        "\x0FtestTransaction"
    end

    it 'returns a serialized protobuf binary string' do
      expect(proposed_transaction.to_proto.force_encoding('BINARY'))
        .to eq(expected_proposed_transaction.dup.force_encoding('BINARY'))
    end
  end

  describe '#to_json' do
    it 'returns a serialized JSON string' do
      expect(proposed_transaction.to_json).to be_a(String)
    end
  end
end
