# frozen_string_literal: true

RSpec.describe Fabric::Identity do
  describe '#new_gateway' do
    context 'when valid client is passed' do
      let(:client) { build(:simple_client) }

      it 'returns a new gateway' do
        gateway = subject.new_gateway(client)

        expect(gateway).to be_a(Fabric::Gateway)
        expect(gateway.client).to be(client)
        expect(gateway.signer).to be_a(described_class)
        expect(gateway.signer).to be(subject)
      end
    end
  end
end
