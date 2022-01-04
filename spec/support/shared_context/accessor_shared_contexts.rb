# frozen_string_literal: true

RSpec.shared_examples 'a gateway accessor' do
  describe '#gateway' do
    it 'returns the gateway' do
      expect(subject.gateway).to be_a(::Fabric::Gateway)
    end
  end

  describe '#client' do
    it 'returns a Fabric::Client' do
      expect(subject.client).to be_a(::Fabric::Client)
    end

    it 'returns the client from gateway' do
      expect(subject.client).to eql(subject.gateway.client)
    end
  end

  describe '#signer' do
    it 'returns a Fabric::Identity' do
      expect(subject.signer).to be_a(::Fabric::Identity)
    end

    it 'returns the signer from the gateway' do
      expect(subject.signer).to eql(subject.gateway.signer)
    end
  end
end

RSpec.shared_examples 'a network accessor' do
  include_examples 'a gateway accessor'

  describe '#network_name' do
    it 'returns the network name from the network' do
      expect(subject.network_name).to eql(subject.network.name)
    end
  end

  describe '#gateway' do
    it 'returns the gateway' do
      expect(subject.gateway).to be_a(::Fabric::Gateway)
    end

    it 'returns the gateway from the network' do
      expect(subject.gateway).to eql(subject.network.gateway)
    end
  end
end

RSpec.shared_examples 'a contract accessor' do
  include_examples 'a network accessor'

  describe '#network' do
    it 'returns the network' do
      expect(subject.network).to be_a(::Fabric::Network)
    end

    it 'returns the network from the contract' do
      expect(subject.network).to eql(subject.contract.network)
    end
  end

  describe '#contract_name' do
    it 'returns the contract_name from the contract' do
      expect(subject.contract_name).to eql(subject.contract.contract_name)
    end
  end

  describe '#chaincode_name' do
    it 'returns the chaincode_name from the contract' do
      expect(subject.chaincode_name).to eql(subject.contract.chaincode_name)
    end
  end
end
