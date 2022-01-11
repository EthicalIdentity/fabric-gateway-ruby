# frozen_string_literal: true

RSpec.describe Fabric::ChaincodeEventsRequest do # rubocop:disable RSpec/FilePath
  subject(:chaincode_events_request) { described_class.new(contract) }

  let(:contract) { build(:contract) }

  describe '#new' do
    it { is_expected.to be_a(described_class) }

    context 'when start_block is not passed' do
      it 'sets contract' do
        expect(chaincode_events_request.contract).to eql(contract)
      end

      it 'sets start_block to nil' do
        expect(chaincode_events_request.start_block).to be_nil
      end
    end

    context 'when start_block is passed' do
      subject(:chaincode_events_request) { described_class.new(contract, start_block: 555) }

      it 'sets contract' do
        expect(chaincode_events_request.contract).to eql(contract)
      end

      it 'sets start_block' do
        expect(chaincode_events_request.start_block).to be(555)
      end
    end
  end
  
  it_behaves_like 'a contract accessor'

  describe '#signed_request' do
    let(:expected_signed_request) do
      '{"request":"Cgd0ZXN0bmV0Eg10ZXN0Y2hhaW5jb2RlGgkKB09yZzFNU1AiAiIA"}'
    end

    it 'returns a new SignedChaincodeEventsRequest' do
      expect(chaincode_events_request.signed_request).to be_a(Gateway::SignedChaincodeEventsRequest)
    end

    it 'returns a new SignedChaincodeEventsRequest with the correct request' do
      expect(chaincode_events_request.signed_request.to_json).to eql(expected_signed_request)
    end

    it 'returns an unsigned SignedChaincodeEventsRequest' do
      expect(chaincode_events_request.signed_request.signature).to be_empty
    end

    context 'when called multiple times' do
      before do
        chaincode_events_request.instance_variable_set(:@signed_request, 'mocked payload')
      end

      it 'returns cached signed_request' do
        5.times { expect(chaincode_events_request.signed_request).to eql('mocked payload') }
      end
    end
  end

  describe '#chaincode_events_request' do
    context 'when start_block is not passed' do
      let(:expected_attributes) do
        {
          channel_id: 'testnet',
          chaincode_id: 'testchaincode',
          identity: "\n\aOrg1MSP",
          start_position: Orderer::SeekPosition.new(next_commit: Orderer::SeekNextCommit.new)
        }
      end

      it 'returns a new ChaincodeEventsRequest' do
        expect(chaincode_events_request.chaincode_events_request).to be_a(Gateway::ChaincodeEventsRequest)
      end

      it 'returns a new ChaincodeEventsRequest with the correct request' do
        expect(chaincode_events_request.chaincode_events_request).to have_attributes(expected_attributes)
      end
    end

    context 'when start_block is passed' do
      subject(:chaincode_events_request) { described_class.new(contract, start_block: 123) }

      let(:expected_attributes) do
        {
          channel_id: 'testnet',
          chaincode_id: 'testchaincode',
          identity: "\n\aOrg1MSP",
          start_position: Orderer::SeekPosition.new(specified: Orderer::SeekSpecified.new(number: 123))
        }
      end

      it 'returns a new ChaincodeEventsRequest' do
        expect(chaincode_events_request.chaincode_events_request).to be_a(Gateway::ChaincodeEventsRequest)
      end

      it 'returns a new ChaincodeEventsRequest with the correct request' do
        expect(chaincode_events_request.chaincode_events_request).to have_attributes(expected_attributes)
      end
    end

    context 'when called multiple times' do
      before do
        chaincode_events_request.instance_variable_set(:@chaincode_events_request, 'mocked payload')
      end

      it 'returns cached chaincode_events_request' do
        5.times { expect(chaincode_events_request.chaincode_events_request).to eql('mocked payload') }
      end
    end
  end

  describe '#request_bytes' do
    let(:expected_request_bytes) do
      "\n\atestnet\x12\rtestchaincode\x1A\t\n\aOrg1MSP\"\x02\"\x00"
    end

    it 'returns protobuf request' do
      expect(chaincode_events_request.request_bytes).to eql(expected_request_bytes)
    end
  end

  describe '#request_digest' do
    let(:expected_request_bytes) do
      "\n\atestnet\x12\rtestchaincode\x1A\t\n\aOrg1MSP\"\x02\"\x00"
    end

    before do
      chaincode_events_request
      allow(Fabric.crypto_suite).to receive(:digest).and_return('mocked digest')
    end

    it 'returns digest of chaincode_events_request' do
      expect(chaincode_events_request.request_digest).to eql('mocked digest')
    end

    it 'calls CryptoSuite.digest with chaincode_events_request bytes' do
      chaincode_events_request.request_digest

      expect(Fabric.crypto_suite).to have_received(:digest).with(expected_request_bytes)
    end
  end

  describe '#signature=' do
    it 'sets signature on the signed request' do
      expect { chaincode_events_request.signature = 'signature' }
        .to change { chaincode_events_request.signed_request.signature }
        .to('signature')
    end
  end

  describe '#sign' do
    context 'when the signed_request is already signed' do
      before do
        chaincode_events_request.signed_request.signature = 'test signature'
      end

      it 'returns nil' do
        expect(chaincode_events_request.sign).to be_nil
      end

      it 'does not call the signer' do
        allow(chaincode_events_request.signer).to receive(:sign)

        chaincode_events_request.sign

        expect(chaincode_events_request.signer).not_to have_received(:sign)
      end

      it 'does not change the signature' do
        expect { chaincode_events_request.sign }.not_to(change(chaincode_events_request, :signature))
      end
    end

    context 'when the proposal is not signed' do
      before do
        allow(chaincode_events_request.signer).to receive(:sign).with(chaincode_events_request.request_bytes).and_return('test generated signature')
        chaincode_events_request.sign
      end

      it 'calls the signer' do
        expect(chaincode_events_request.signer).to have_received(:sign)
      end

      it 'sets the signature' do
        expect(chaincode_events_request.signature).to eql('test generated signature')
      end
    end
  end

  describe '#signature' do
    before do
      chaincode_events_request.signed_request.signature = 'test signature'
    end

    it 'calls the signature from the signed_request' do
      expect(chaincode_events_request.signature).to eql('test signature')
    end
  end

  describe '#signed?' do
    context 'when signed_request signature is empty' do
      it 'returns false' do
        expect(chaincode_events_request.signed?).to be false
      end
    end

    context 'when signed_request signature is not empty' do
      before do
        chaincode_events_request.signature = 'signature'
      end

      it 'returns true' do
        expect(chaincode_events_request.signed?).to be true
      end
    end
  end

  describe '#get_events' do
    before do
      allow(contract.client).to receive(:chaincode_events)
    end

    it 'passes the signed_request to the client' do
      chaincode_events_request.get_events

      expect(contract.client).to have_received(:chaincode_events).with(chaincode_events_request.signed_request,
                                                                       anything)
    end

    context 'when options are passed' do
      it 'calls the client chaincode_events with the options' do
        chaincode_events_request.get_events({ test: 'test' })

        expect(contract.client).to have_received(:chaincode_events).with(anything, test: 'test')
      end
    end

    context 'when options are not passed' do
      it 'calls the client chaincode_events with an empty hash' do
        chaincode_events_request.get_events

        expect(contract.client).to have_received(:chaincode_events).with(anything, {})
      end
    end

    context 'when a block is passed' do
      let(:passed_block) { proc {} }

      it 'passes the block to the chaincode_events client call' do # rubocop:disable RSpec/MultipleExpectations
        chaincode_events_request.get_events(&passed_block)

        expect(contract.client).to have_received(:chaincode_events)
          .with(chaincode_events_request.signed_request, {}) do |&block|
          expect(block).to eql(passed_block)
        end
      end
    end

    context 'when a block is not passed' do
      let(:passed_block) { proc {} }

      it 'passes the block to the chaincode_events client call' do # rubocop:disable RSpec/MultipleExpectations
        chaincode_events_request.get_events

        expect(contract.client).to have_received(:chaincode_events)
          .with(chaincode_events_request.signed_request, {}) do |&block|
          expect(block).to be(nil)
        end
      end
    end

    context 'when the request is not signed' do
      before do
        allow(chaincode_events_request.signer).to receive(:sign).with(chaincode_events_request.request_bytes).and_return('test generated signature')
        chaincode_events_request.get_events
      end

      it 'calls the signer' do
        expect(chaincode_events_request.signer).to have_received(:sign)
      end

      it 'sets the signature' do
        expect(chaincode_events_request.signature).to eql('test generated signature')
      end
    end

    context 'when the request is signed' do
      before do
        chaincode_events_request.signed_request.signature = 'test signature'
      end

      it 'does not call the signer' do
        allow(chaincode_events_request.signer).to receive(:sign)

        chaincode_events_request.get_events

        expect(chaincode_events_request.signer).not_to have_received(:sign)
      end

      it 'does not change the signature' do
        expect { chaincode_events_request.get_events }.not_to(change(chaincode_events_request, :signature))
      end
    end
  end
end
