RSpec.describe Fabric::Network do
  describe '#new' do
    let(:client) { build(:simple_client) }
    let(:signer) { Fabric::Identity.new }
    it 'returns a new network' do
      network=Fabric::Network.new(client, signer, 'test')
      expect(network).to be_a(Fabric::Network)

      expect(network.client).to be(client)
      expect(network.signer).to be(signer)
      expect(network.name).to eq('test')
    end
  end
end