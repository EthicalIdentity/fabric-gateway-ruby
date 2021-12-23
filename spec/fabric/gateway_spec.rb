# frozen_string_literal: true

RSpec.describe Fabric::Gateway do
  describe '#new' do
    context 'when invalid params are passed' do
      it {
        expect do
          described_class.new(nil,
                              nil)
        end.to raise_error(Fabric::InvalidArgument).with_message('signer must be Fabric::Identity')
      }

      it {
        expect do
          described_class.new(Fabric::Identity.new,
                              nil)
        end.to raise_error(Fabric::InvalidArgument).with_message('client must be Fabric::Client')
      }
    end

    context 'when passing valid params' do
      let(:gateway) { described_class.new(signer, client) }

      let(:signer) { Fabric::Identity.new }
      let(:client) { build(:simple_client) }

      it { expect(gateway).to be_a(described_class) }

      it { expect(gateway.signer).to be(signer) }
      it { expect(gateway.client).to be(client) }
    end
  end

  describe '#new_network' do
    let(:gateway) { build(:gateway) }

    let(:network) { gateway.new_network('test123') }

    it { expect(network).to be_a(Fabric::Network) }
    it { expect(network.client).to be(gateway.client) }
    it { expect(network.name).to eq('test123') }
  end
end
