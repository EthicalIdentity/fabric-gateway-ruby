RSpec.describe Fabric::Gateway do
  describe '#new' do
    context 'when invalid params are passed' do
      it { expect { Fabric::Gateway.new(nil, nil) }.to raise_error(Fabric::InvalidArgument).with_message('signer must be Fabric::Identity') }
      it { expect { Fabric::Gateway.new(Fabric::Identity.new, nil) }.to raise_error(Fabric::InvalidArgument).with_message('client must be Fabric::Client') }
    end

    context 'when passing valid params' do
      let(:signer) { Fabric::Identity.new }
      let(:client) { build(:simple_client) }
      it 'returns a new gateway' do
        gateway = Fabric::Gateway.new(signer, client)

        expect(gateway).to be_a(Fabric::Gateway)

        expect(gateway.signer).to be(signer)
        expect(gateway.client).to be(client)
      end
    end
  end
end