RSpec.describe Fabric::Proposal do
  subject(:proposal) { described_class.new(proposed_transaction) }

  let(:proposed_transaction) { build(:proposed_transaction) }

  describe 'attribute readers' do
    let(:expected_attributes) do
      {
        proposed_transaction: proposed_transaction,
        contract: proposed_transaction.contract,
        signer: proposed_transaction.signer,
        gateway: proposed_transaction.gateway,
        network_name: 'testnet',
        chaincode_name: 'testchaincode',
        contract_name: 'testcontract',
        transaction_id: proposed_transaction.transaction_id,
        proposal: proposed_transaction.proposal
      }
    end

    it { is_expected.to have_attributes(expected_attributes) }
  end

  describe '#to_proto' do
    it 'calls to_proto of the proposed transaction' do
      allow(proposed_transaction).to receive(:to_proto)

      proposal.to_proto

      expect(proposed_transaction).to have_received(:to_proto)
    end
  end

  describe '#digest' do
    let(:expected_digest) do
      Fabric.crypto_suite.decode_hex('2053dbbf6ec7135c4e994d3464c478db6f48d3ca21052c8f44915edc96e02c39')
    end

    before do
      allow(proposed_transaction.proposal).to receive(:to_proto).and_return('static')
    end

    it 'returns digest of binary proposal' do
      expect(proposal.digest).to eql(expected_digest)
    end
  end

  describe '#signature=' do
    it 'sets the signature' do
      proposal.signature = 'something_random'

      expect(proposal.proposed_transaction.signed_proposal.signature).to eql('something_random')
    end
  end

  describe '#signature' do
    it 'calls the signature from the signed_proposal' do
      allow(proposed_transaction.signed_proposal).to receive(:signature).and_return('some_signature')

      expect(proposal.signature).to eql('some_signature')
    end
  end

  describe '#signed?' do
    context 'when signature is empty' do
      before do
        proposed_transaction.signed_proposal.signature = ''
      end

      it 'returns false' do
        expect(proposal.signed?).to be false
      end
    end

    context 'when signature exists' do
      before do
        proposed_transaction.signed_proposal.signature = 'fake signature'
      end

      it 'returns false' do
        expect(proposal.signed?).to be true
      end
    end
  end

  describe 'sign' do
    context 'when the proposal is already signed' do
      before do
        proposed_transaction.signed_proposal.signature = 'test signature'
      end

      it 'returns true' do
        expect(proposal.sign).to be_nil
      end

      it 'does not call the signer' do
        allow(proposal.signer).to receive(:sign)

        proposal.sign

        expect(proposal.signer).not_to have_received(:sign)
      end

      it 'does not change the signature' do
        expect { proposal.sign }.not_to(change(proposal, :signature))
      end
    end

    context 'when the proposal is not signed' do
      before do
        allow(proposal.signer).to receive(:sign).with(proposal.proposal.to_proto).and_return('test generated signature')
        proposal.sign
      end

      it 'calls the signer' do
        expect(proposal.signer).to have_received(:sign)
      end

      it 'sets the signature' do
        expect(proposal.signature).to eql('test generated signature')
      end
    end
  end
end
