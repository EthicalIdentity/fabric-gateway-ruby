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
      subject(:gateway) { described_class.new(signer, client) }

      let(:signer) { Fabric::Identity.new }
      let(:client) { build(:simple_client) }

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(signer: signer, client: client) }
    end
  end

  describe '#new_network' do
    subject(:gateway) { build(:gateway) }

    let(:network) { gateway.new_network('test123') }
    let(:expected_attributes) do
      {
        gateway: gateway,
        client: gateway.client,
        signer: gateway.signer,
        name: 'test123'
      }
    end

    it 'creates a Fabric::Network' do
      expect(network).to be_a(Fabric::Network)
    end

    it 'assigns the attributes to the network' do
      expect(network).to have_attributes(expected_attributes)
    end
  end
end
