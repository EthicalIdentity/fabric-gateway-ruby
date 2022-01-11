# frozen_string_literal: true

RSpec.describe Fabric::Proposal do # rubocop:disable RSpec/FilePath
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

  it_behaves_like 'a contract accessor'

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

  describe '#sign' do
    context 'when the proposal is already signed' do
      before do
        proposed_transaction.signed_proposal.signature = 'test signature'
      end

      it 'returns nil' do
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

  describe '#evaluate' do
    # please refer to support/shared_context/client_mocks - it is where all the magic is happening!
    include_context 'client mocks'

    before do
      setup_evaluate_mock(proposed_transaction.client, :client_evaluate_response)
    end

    context 'when the proposal is not signed' do
      let!(:response) { proposal.evaluate }

      it 'sets the signature' do
        expect(sent_evaluate_request.proposed_transaction.signature).not_to be_empty
      end

      it 'returns an evaluate response' do
        expect(response).to be(:client_evaluate_response)
      end

      it 'calls client evaluate' do
        expect(proposed_transaction.client).to have_received(:evaluate)
      end

      it 'sends no call options' do
        expect(sent_call_options).to eql({})
      end
    end

    context 'when the proposal is signed' do
      before do
        proposal.signature = 'a fake signature'
      end

      let!(:response) { proposal.evaluate }

      it 'does not change the signature' do
        expect(sent_evaluate_request.proposed_transaction.signature).to eql('a fake signature')
      end

      it 'returns an evaluate response' do
        expect(response).to be(:client_evaluate_response)
      end

      it 'calls client evaluate' do
        expect(proposed_transaction.client).to have_received(:evaluate)
      end

      it 'sends no call options' do
        expect(sent_call_options).to eql({})
      end
    end

    context 'when options are passed' do
      let!(:response) { proposal.evaluate({ some: 'option' }) }

      it 'sets the signature' do
        expect(sent_evaluate_request.proposed_transaction.signature).not_to be_empty
      end

      it 'returns an evaluate response' do
        expect(response).to be(:client_evaluate_response)
      end

      it 'calls client evaluate' do
        expect(proposed_transaction.client).to have_received(:evaluate)
      end

      it 'sends call options' do
        expect(sent_call_options).to eql({ some: 'option' })
      end
    end
  end

  describe '#endorse' do
    # please refer to support/shared_context/client_mocks - it is where all the magic is happening!
    include_context 'client mocks'

    before do
      setup_endorse_mock(proposed_transaction.client, nil)
    end

    context 'when endorse_response missing prepared_transaction' do
      before do
        setup_endorse_mock(proposed_transaction.client, nil)
      end

      it 'raises an error' do
        expect { proposal.endorse }
          .to raise_error(Fabric::Error).with_message('Missing transaction envelope')
      end
    end

    context 'when the proposal is not signed' do
      before do
        allow(Fabric::Transaction).to receive(:new).and_return(:mocked_transaction)
        setup_endorse_mock(proposed_transaction.client, expected_envelope)
      end

      let(:expected_envelope) { Common::Envelope.new(payload: 'fake payload') }
      let!(:response) { proposal.endorse }

      it 'sets the signature' do
        expect(proposed_transaction.signed_proposal.signature).not_to be_empty
      end

      it 'returns a new transaction' do
        expect(response).to be(:mocked_transaction)
      end

      it 'passes the right arguments to the transaction constructor' do
        expect(Fabric::Transaction).to have_received(:new).with(
          proposed_transaction.network,
          Gateway::PreparedTransaction.new(transaction_id: proposed_transaction.transaction_id,
                                           envelope: expected_envelope)
        )
      end

      it 'calls client endorse' do
        expect(proposed_transaction.client).to have_received(:endorse)
      end

      it 'sends no call options' do
        expect(sent_call_options).to eql({})
      end
    end

    context 'when the proposal is signed' do
      before do
        proposal.signature = 'a fake signature'
        allow(Fabric::Transaction).to receive(:new).and_return(:mocked_transaction)
        setup_endorse_mock(proposed_transaction.client, expected_envelope)
      end

      let(:expected_envelope) { Common::Envelope.new(payload: 'fake payload') }
      let!(:response) { proposal.endorse }

      it 'does not change the signature' do
        expect(proposed_transaction.signed_proposal.signature).to eql('a fake signature')
      end

      it 'returns a new transaction' do
        expect(response).to be(:mocked_transaction)
      end

      it 'passes the right arguments to the transaction constructor' do
        expect(Fabric::Transaction).to have_received(:new).with(
          proposed_transaction.network,
          Gateway::PreparedTransaction.new(transaction_id: proposed_transaction.transaction_id,
                                           envelope: expected_envelope)
        )
      end

      it 'calls client evaluate' do
        expect(proposed_transaction.client).to have_received(:endorse)
      end

      it 'sends no call options' do
        expect(sent_call_options).to eql({})
      end
    end

    context 'when options are passed' do
      before do
        allow(Fabric::Transaction).to receive(:new).and_return(:mocked_transaction)
        setup_endorse_mock(proposed_transaction.client, expected_envelope)
      end

      let(:expected_envelope) { Common::Envelope.new(payload: 'fake payload') }
      let!(:response) { proposal.endorse({ some: 'option' }) }

      it 'sets the signature' do
        expect(proposed_transaction.signed_proposal.signature).not_to be_empty
      end

      it 'returns a new transaction' do
        expect(response).to be(:mocked_transaction)
      end

      it 'passes the right arguments to the transaction constructor' do
        expect(Fabric::Transaction).to have_received(:new).with(
          proposed_transaction.network,
          Gateway::PreparedTransaction.new(transaction_id: proposed_transaction.transaction_id,
                                           envelope: expected_envelope)
        )
      end

      it 'calls client endorse' do
        expect(proposed_transaction.client).to have_received(:endorse)
      end

      it 'sends call options' do
        expect(sent_call_options).to eql({ some: 'option' })
      end
    end
  end

  describe '#new_evaluate_request' do
    let!(:response) { proposal.new_evaluate_request }

    it 'returns an EvaluateRequest' do
      expect(response).to be_a(::Gateway::EvaluateRequest)
    end

    it 'sets the channel_id' do
      expect(response.channel_id).to eql('testnet')
    end

    it 'sets the proposed_transaction' do
      expect(response.proposed_transaction).to eql(proposed_transaction.proposed_transaction.proposal)
    end

    it 'sets the target_organizations' do
      expect(response.target_organizations).to eql([])
    end
  end

  describe '#new_endorse_request' do
    let!(:response) { proposal.new_endorse_request }

    it 'returns an EndorseRequest' do
      expect(response).to be_a(::Gateway::EndorseRequest)
    end

    it 'sets the channel_id' do
      expect(response.channel_id).to eql('testnet')
    end

    it 'sets the proposed_transaction' do
      expect(response.proposed_transaction).to eql(proposed_transaction.proposed_transaction.proposal)
    end

    it 'sets the target_organizations' do
      expect(response.endorsing_organizations).to eql([])
    end
  end

  describe '#new_prepared_transaction' do
    let(:expected_envelope) { Common::Envelope.new(payload: 'fake payload') }
    let!(:response) { proposal.new_prepared_transaction(expected_envelope) }

    it 'returns a PreparedTransaction' do
      expect(response).to be_a(::Gateway::PreparedTransaction)
    end

    it 'sets the transaction_id' do
      expect(response.transaction_id).to eql(proposed_transaction.transaction_id)
    end

    it 'sets the envelope' do
      expect(response.envelope).to eql(expected_envelope)
    end
  end
end
