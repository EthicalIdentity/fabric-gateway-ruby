# frozen_string_literal: true

RSpec.describe Fabric::Transaction do  # rubocop:disable RSpec/FilePath
  subject(:transaction) { described_class.new(network, prepared_transaction) }

  let(:network) { build(:network) }
  let(:prepared_transaction) { Gateway::PreparedTransaction.new(envelope: envelope, transaction_id: 'abc123') }
  let(:envelope) { Common::Envelope.new(payload: 'test payload') }

  describe '#new' do
    it { is_expected.to be_a(described_class) }
    it { is_expected.to have_attributes(network: network, prepared_transaction: prepared_transaction) }

    it 'creates an envelope' do
      expect(transaction.envelope).to be_a(Fabric::Envelope)
    end

    it 'assigns the passed envelope to the transaction envelope' do
      expect(transaction.envelope.envelope).to eql(envelope)
    end
  end

  describe '#result' do
    let(:commit_status_response) { Gateway::CommitStatusResponse.new(result: :VALID) }

    before do
      allow(network.client).to receive(:commit_status).and_return(commit_status_response)
      allow(transaction.envelope).to receive(:result).and_return('test result')
    end

    context 'when check_status is not passed and status is successful' do
      it 'returns the result' do
        expect(transaction.result).to eql('test result')
      end
    end

    context 'when check_status is not passed and status is unsuccessful' do
      let(:commit_status_response) { Gateway::CommitStatusResponse.new(result: :BAD_PAYLOAD) }
      let(:expected_error_message) { 'Transaction abc123 failed to commit with status code 2 - BAD_PAYLOAD' }

      it 'raises an error' do
        expect { transaction.result }.to raise_error(Fabric::CommitError).with_message(expected_error_message)
      end
    end

    context 'when check_status is true and status is successful' do
      it 'returns the result' do
        expect(transaction.result(check_status: true)).to eql('test result')
      end
    end

    context 'when check_status is true and status is unsuccessful' do
      let(:commit_status_response) { Gateway::CommitStatusResponse.new(result: :BAD_PAYLOAD) }
      let(:expected_error_message) { 'Transaction abc123 failed to commit with status code 2 - BAD_PAYLOAD' }

      it 'raises an error' do
        expect { transaction.result(check_status: true) }
          .to raise_error(Fabric::CommitError).with_message(expected_error_message)
      end
    end

    context 'when check_status is false' do
      it 'returns the result' do
        expect(transaction.result(check_status: false)).to eql('test result')
      end

      it 'does not call commit_status' do
        expect(network.client).not_to have_received(:commit_status)
      end
    end
  end

  describe '#transaction_id' do
    it 'returns the transaction id' do
      expect(transaction.transaction_id).to eql('abc123')
    end
  end

  describe '#submit' do
    let(:expected_submit_request) do
      Gateway::SubmitRequest.new(
        transaction_id: 'abc123',
        channel_id: 'testnet',
        prepared_transaction: Common::Envelope.new(payload: 'test payload', signature: 'test signature')
      )
    end

    before do
      allow(network.client).to receive(:submit)
      allow(network.signer).to receive(:sign).and_return('test signature')
    end

    context 'when options are passed' do
      it 'submits the transaction with the options' do
        transaction.submit(options: { some: 'option' })
        expect(network.client).to have_received(:submit).with(expected_submit_request, options: { some: 'option' })
      end
    end

    context 'when options are not passed' do
      it 'submits the transaction with the options' do
        transaction.submit
        expect(network.client).to have_received(:submit).with(expected_submit_request, {})
      end
    end
  end

  describe '#sign_submit_request' do
    before do
      allow(network.signer).to receive(:sign).and_return('test signature')
    end

    context 'when submit_request is already signed' do
      let(:envelope) { Common::Envelope.new(payload: 'test payload', signature: 'already signed') }

      it 'does not call sign' do
        transaction.sign_submit_request
        expect(network.signer).not_to have_received(:sign)
      end

      it 'does not change the signature' do
        expect { transaction.sign_submit_request }.not_to(change { transaction.envelope.envelope.signature })
      end
    end

    context 'when submit_request is not already signed' do
      let(:envelope) { Common::Envelope.new(payload: 'test payload') }

      it 'does calls sign' do
        transaction.sign_submit_request
        expect(network.signer).to have_received(:sign)
      end

      it 'changes the signature' do
        expect { transaction.sign_submit_request }.to(change do
                                                        transaction.envelope.envelope.signature
                                                      end.from('').to('test signature'))
      end
    end
  end

  describe '#submit_request_signed?' do
    context 'when signature is set' do
      let(:envelope) { Common::Envelope.new(payload: 'test payload', signature: 'already signed') }

      it 'returns true' do
        expect(transaction.submit_request_signed?).to be(true)
      end
    end

    context 'when signature is not set' do
      let(:envelope) { Common::Envelope.new(payload: 'test payload') }

      it 'returns false' do
        expect(transaction.submit_request_signed?).to be(false)
      end
    end
  end

  describe '#submit_request_digest' do
    before do
      allow(transaction.envelope).to receive(:payload_digest).and_return('payload digest')
    end

    it 'returns the digest of the payload' do
      expect(transaction.submit_request_digest).to eql('payload digest')
    end
  end

  describe '#submit_request_signature=' do
    before do
      allow(transaction.envelope).to receive(:signature=)
    end

    it 'sets the signature on the envelope' do
      transaction.submit_request_signature = 'test signature'

      expect(transaction.envelope).to have_received(:signature=).with('test signature')
    end
  end

  describe '#status' do
    let(:commit_status_response) { Gateway::CommitStatusResponse.new(result: :VALID) }

    before do
      allow(network.client).to receive(:commit_status).and_return(commit_status_response)
      allow(transaction.envelope).to receive(:result).and_return('test result')
    end

    context 'when called more than once' do
      it 'calls commit_status only once' do
        5.times { transaction.status }

        expect(network.client).to have_received(:commit_status).once
      end
    end

    context 'when options are passed' do
      let(:expected_commit_status_request) do
        Gateway::SignedCommitStatusRequest.new(
          request: Gateway::CommitStatusRequest.new(
            transaction_id: 'abc123',
            channel_id: 'testnet',
            identity: network.signer.to_proto
          ).to_proto,
          signature: 'test signature'
        )
      end

      before do
        allow(network.signer).to receive(:sign).and_return('test signature')
      end

      it 'calls commit_status with the options' do
        transaction.status(options: { some: 'option' })
        expect(network.client).to have_received(:commit_status).with(expected_commit_status_request,
                                                                     options: { some: 'option' })
      end
    end

    context 'when options are not passed' do
      let(:expected_commit_status_request) do
        Gateway::SignedCommitStatusRequest.new(
          request: Gateway::CommitStatusRequest.new(
            transaction_id: 'abc123',
            channel_id: 'testnet',
            identity: network.signer.to_proto
          ).to_proto,
          signature: 'test signature'
        )
      end

      before do
        allow(network.signer).to receive(:sign).and_return('test signature')
      end

      it 'calls commit_status with the options' do
        transaction.status
        expect(network.client).to have_received(:commit_status).with(expected_commit_status_request, {})
      end
    end
  end

  describe '#status_request_digest' do
    before do
      allow(transaction.signed_commit_status_request).to receive(:request).and_return('the request to digest')
      allow(Fabric.crypto_suite).to receive(:digest).and_return('test hash')
    end

    it 'returns the digest of the signed_commit_status_request request' do
      expect(transaction.status_request_digest).to eql('test hash')
    end

    it 'calls digest with the signed_commit_status_request request' do
      transaction.status_request_digest
      expect(Fabric.crypto_suite).to have_received(:digest).with('the request to digest')
    end
  end

  describe '#status_request_signature=' do
    before do
      allow(transaction.signed_commit_status_request).to receive(:signature=)
    end

    it 'sets the signature on the envelope' do
      transaction.status_request_signature = 'test signature'

      expect(transaction.signed_commit_status_request).to have_received(:signature=).with('test signature')
    end
  end

  describe '#status_request_signed?' do
    context 'when signature is set' do
      before do
        transaction.status_request_signature = 'already signed'
      end

      it 'returns true' do
        expect(transaction.status_request_signed?).to be(true)
      end
    end

    context 'when signature is not set' do
      it 'returns false' do
        expect(transaction.status_request_signed?).to be(false)
      end
    end
  end

  describe '#sign_status_request' do
    before do
      allow(network.signer).to receive(:sign).and_return('test signature')
    end

    context 'when status_request is already signed' do
      before do
        transaction.signed_commit_status_request.signature = 'already signed'
      end

      it 'does not call sign' do
        transaction.sign_status_request
        expect(network.signer).not_to have_received(:sign)
      end

      it 'does not change the signature' do
        expect { transaction.sign_status_request }.not_to(change { transaction.signed_commit_status_request.signature })
      end
    end

    context 'when status_request is not already signed' do
      before do
        transaction.signed_commit_status_request.signature = ''
      end

      it 'does calls sign' do
        transaction.sign_status_request
        expect(network.signer).to have_received(:sign)
      end

      it 'changes the signature' do
        expect { transaction.sign_status_request }.to(change do
                                                        transaction.signed_commit_status_request.signature
                                                      end.from('').to('test signature'))
      end
    end
  end

  describe '#signed_commit_status_request' do
    context 'when called more than once' do
      before do
        allow(network.signer).to receive(:to_proto).and_return('test identity')
      end

      it 'calls signer.to_proto only once' do
        5.times { transaction.signed_commit_status_request }

        expect(network.signer).to have_received(:to_proto).once
      end
    end
  end
end
