# frozen_string_literal: true

RSpec.describe Fabric::Envelope do # rubocop:disable RSpec/FilePath
  subject(:envelope) { described_class.new(envelope_pb) }

  let(:envelope_pb) { Common::Envelope.new }

  describe '#new' do
    it { is_expected.to be_a(described_class) }

    it 'sets envelope to passed in envelope' do
      expect(envelope.envelope).to eql(envelope_pb)
    end
  end

  describe '#signed?' do
    context 'when envelope signature is empty' do
      it 'returns false' do
        expect(envelope.signed?).to be false
      end
    end

    context 'when envelope signature is not empty' do
      let(:envelope_pb) { Common::Envelope.new(signature: 'signature') }

      it 'returns true' do
        expect(envelope.signed?).to be true
      end
    end
  end

  describe '#payload_bytes' do
    context 'when envelope payload is empty' do
      it 'returns blank string' do
        expect(envelope.payload_bytes).to eql('')
      end
    end

    context 'when envelope payload is not empty' do
      let(:envelope_pb) { Common::Envelope.new(payload: 'payload') }

      it 'returns payload' do
        expect(envelope.payload_bytes).to eql('payload')
      end
    end
  end

  describe '#payload_digest' do
    let(:envelope_pb) { Common::Envelope.new(payload: 'payload') }

    before do
      allow(Fabric.crypto_suite).to receive(:digest).and_return('mocked digest')
    end

    it 'returns digest of payload' do
      expect(envelope.payload_digest).to eql('mocked digest')
    end

    it 'calls CryptoSuite.digest with payload' do
      envelope.payload_digest

      expect(Fabric.crypto_suite).to have_received(:digest).with('payload')
    end
  end

  describe '#signature=' do
    it 'sets signature on envelope' do
      expect { envelope.signature = 'signature' }.to change { envelope.envelope.signature }.to('signature')
    end
  end

  describe '#result' do
    # we are testing strictly off of the logical possibilities within the code
    # we have no idea what the real-life errors may possibly be

    let(:common_header_serialized) do
      Common::Header.new(
        channel_header: Common::ChannelHeader.new(
          channel_id: 'channel_id'
        ).to_proto
      )
    end
    let(:payload) do
      Common::Payload.new(header: common_header_serialized, data: transactions.to_proto)
    end
    let(:envelope_pb) { Common::Envelope.new(payload: payload.to_proto) }

    context 'when there is no result' do
      let(:transactions) do
        Protos::Transaction.new(
          actions: []
        )
      end

      let(:expected_error_message) do
        'No proposal response found: []'
      end

      it 'raises an exception' do
        expect { envelope.result }
          .to raise_error(Fabric::Error, expected_error_message)
      end
    end

    context 'when there is a result' do
      let(:transactions) do
        Protos::Transaction.new(
          actions: [
            Protos::TransactionAction.new(
              payload: Protos::ChaincodeActionPayload.new(
                action: Protos::ChaincodeEndorsedAction.new(
                  proposal_response_payload: Protos::ProposalResponsePayload.new(
                    extension: Protos::ChaincodeAction.new(
                      response: Protos::Response.new(
                        status: 200,
                        message: '',
                        payload: 'first'
                      )
                    ).to_proto
                  ).to_proto
                )
              ).to_proto
            )
          ]
        )
      end

      it 'returns the result' do
        expect(envelope.result).to eql('first')
      end
    end

    context 'when there are multiple transaction actions' do
      let(:transactions) do
        Protos::Transaction.new(
          actions: [
            Protos::TransactionAction.new(
              payload: Protos::ChaincodeActionPayload.new(
                action: Protos::ChaincodeEndorsedAction.new(
                  proposal_response_payload: Protos::ProposalResponsePayload.new(
                    extension: Protos::ChaincodeAction.new(
                      response: Protos::Response.new(
                        status: 200,
                        message: '',
                        payload: 'first'
                      )
                    ).to_proto
                  ).to_proto
                )
              ).to_proto
            ),
            Protos::TransactionAction.new(
              payload: Protos::ChaincodeActionPayload.new(
                action: Protos::ChaincodeEndorsedAction.new(
                  proposal_response_payload: Protos::ProposalResponsePayload.new(
                    extension: Protos::ChaincodeAction.new(
                      response: Protos::Response.new(
                        status: 200,
                        message: '',
                        payload: 'second'
                      )
                    ).to_proto
                  ).to_proto
                )
              ).to_proto
            ),
            Protos::TransactionAction.new(
              payload: Protos::ChaincodeActionPayload.new(
                action: Protos::ChaincodeEndorsedAction.new(
                  proposal_response_payload: Protos::ProposalResponsePayload.new(
                    extension: Protos::ChaincodeAction.new(
                      response: Protos::Response.new(
                        status: 200,
                        message: '',
                        payload: 'third'
                      )
                    ).to_proto
                  ).to_proto
                )
              ).to_proto
            )
          ]
        )
      end

      it 'returns only the first result' do
        expect(envelope.result).to eql('first')
      end
    end

    context 'when there are errors and a success' do
      let(:transactions) do
        Protos::Transaction.new(
          actions: [
            Protos::TransactionAction.new(
              payload: Protos::ChaincodeActionPayload.new.to_proto
            ),
            Protos::TransactionAction.new(
              payload: Protos::ChaincodeActionPayload.new(
                action: Protos::ChaincodeEndorsedAction.new(
                  proposal_response_payload: Protos::ProposalResponsePayload.new(
                    extension: Protos::ChaincodeAction.new.to_proto
                  ).to_proto
                )
              ).to_proto
            ),
            Protos::TransactionAction.new(
              payload: Protos::ChaincodeActionPayload.new(
                action: Protos::ChaincodeEndorsedAction.new(
                  proposal_response_payload: Protos::ProposalResponsePayload.new(
                    extension: Protos::ChaincodeAction.new(
                      response: Protos::Response.new(
                        status: 200,
                        message: '',
                        payload: 'third'
                      )
                    ).to_proto
                  ).to_proto
                )
              ).to_proto
            )
          ]
        )
      end

      it 'returns the first successful result' do
        expect(envelope.result).to eql('third')
      end
    end

    context 'when there are only errors' do
      let(:transactions) do
        Protos::Transaction.new(
          actions: [
            Protos::TransactionAction.new(
              payload: Protos::ChaincodeActionPayload.new.to_proto
            ),
            Protos::TransactionAction.new(
              payload: Protos::ChaincodeActionPayload.new(
                action: Protos::ChaincodeEndorsedAction.new(
                  proposal_response_payload: Protos::ProposalResponsePayload.new(
                    extension: Protos::ChaincodeAction.new.to_proto
                  ).to_proto
                )
              ).to_proto
            )
          ]
        )
      end

      let(:expected_error_message) do
        'No proposal response found: ' \
          '[#<Fabric::Error: Missing endorsed action>, #<Fabric::Error: Missing chaincode response>]'
      end

      it 'raises an exception' do
        expect { envelope.result }
          .to raise_error(Fabric::Error, expected_error_message)
      end
    end
  end

  describe '#payload' do
    let(:common_header) do
      Common::Header.new(
        channel_header: Common::ChannelHeader.new(
          channel_id: 'channel_id'
        ).to_proto
      )
    end

    let(:payload) do
      Common::Payload.new(header: common_header, data: 'not parsed')
    end

    let(:envelope_pb) { Common::Envelope.new(payload: payload.to_proto) }

    it 'returns deserialized payload' do
      expect(envelope.payload).to eql(payload)
    end

    context 'when called multiple times' do
      before do
        envelope.instance_variable_set(:@payload, 'mocked payload')
      end

      it 'returns cached payload' do
        5.times { expect(envelope.payload).to eql('mocked payload') }
      end
    end
  end

  describe '#header' do
    let(:common_header) do
      Common::Header.new(
        channel_header: Common::ChannelHeader.new(
          channel_id: 'channel_id'
        ).to_proto
      )
    end
    let(:payload) do
      Common::Payload.new(header: common_header, data: 'not parsed')
    end
    let(:envelope_pb) { Common::Envelope.new(payload: payload.to_proto) }

    it 'returns the deserialized header' do
      expect(envelope.header).to eql(common_header)
    end

    context 'when it is called multiple times' do
      before do
        envelope.instance_variable_set(:@header, 'mocked header')
      end

      it 'returns cached header' do
        5.times { expect(envelope.header).to eql('mocked header') }
      end
    end

    context 'when header is missing' do
      let(:payload) do
        Common::Payload.new(data: 'not parsed')
      end

      it 'raises an error' do
        expect { envelope.header }.to raise_error(Fabric::Error).with_message('Missing header')
      end
    end
  end

  describe '#channel_header' do
    let(:common_header) do
      Common::Header.new(
        channel_header: Common::ChannelHeader.new(
          channel_id: 'channel_id'
        ).to_proto
      )
    end
    let(:payload) do
      Common::Payload.new(header: common_header, data: 'not parsed')
    end
    let(:envelope_pb) { Common::Envelope.new(payload: payload.to_proto) }

    it 'returns the deserialized channel header' do
      expect(envelope.channel_header).to eql(Common::ChannelHeader.new(channel_id: 'channel_id'))
    end

    context 'when it is called multiple times' do
      before do
        envelope.instance_variable_set(:@channel_header, 'mocked channel header')
      end

      it 'returns cached channel header' do
        5.times { expect(envelope.channel_header).to eql('mocked channel header') }
      end
    end
  end

  describe '#channel_name' do
    let(:common_header) do
      Common::Header.new(
        channel_header: Common::ChannelHeader.new(
          channel_id: 'channel_id'
        ).to_proto
      )
    end
    let(:payload) do
      Common::Payload.new(header: common_header, data: 'not parsed')
    end
    let(:envelope_pb) { Common::Envelope.new(payload: payload.to_proto) }

    it 'returns the channel name' do
      expect(envelope.channel_name).to eql('channel_id')
    end
  end

  describe 'transaction' do
    let(:transactions) do
      Protos::Transaction.new(
        actions: [
          Protos::TransactionAction.new(
            payload: Protos::ChaincodeActionPayload.new(
              action: Protos::ChaincodeEndorsedAction.new(
                proposal_response_payload: Protos::ProposalResponsePayload.new(
                  extension: Protos::ChaincodeAction.new(
                    response: Protos::Response.new(
                      status: 200,
                      message: '',
                      payload: 'first'
                    )
                  ).to_proto
                ).to_proto
              )
            ).to_proto
          )
        ]
      )
    end

    let(:common_header_serialized) do
      Common::Header.new(
        channel_header: Common::ChannelHeader.new(
          channel_id: 'channel_id'
        ).to_proto
      )
    end
    let(:payload) do
      Common::Payload.new(header: common_header_serialized, data: transactions.to_proto)
    end
    let(:envelope_pb) { Common::Envelope.new(payload: payload.to_proto) }

    it 'returns deserialized transaction' do
      expect(envelope.transaction).to eql(transactions)
    end

    context 'when called multiple times' do
      before do
        envelope.instance_variable_set(:@transaction, 'mocked transaction')
      end

      it 'returns cached transaction' do
        5.times { expect(envelope.transaction).to eql('mocked transaction') }
      end
    end
  end
end
