RSpec.describe Fabric::Contract do
  subject(:contract) { described_class.new(network, 'testchaincode', 'testcontract') }

  let(:signer) { build(:identity, :user1) }
  let(:gateway) { build(:gateway, signer: signer) }
  let(:network) { build(:network, gateway: gateway) }

  describe '#new' do
    context 'when contract_name is not passed' do
      subject(:contract) { described_class.new(network, 'testchaincode') }

      let(:expected_attributes) do
        {
          client: gateway.client,
          signer: signer,
          gateway: gateway,
          network: network,
          network_name: 'testnet',
          chaincode_name: 'testchaincode',
          contract_name: ''
        }
      end

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(expected_attributes) }
    end

    context 'when contract_name is passed' do
      subject(:contract) { described_class.new(network, 'testchaincode', 'testcontract') }

      let(:expected_attributes) do
        {
          client: gateway.client,
          signer: signer,
          gateway: gateway,
          network: network,
          network_name: 'testnet',
          chaincode_name: 'testchaincode',
          contract_name: 'testcontract'
        }
      end

      it { is_expected.to be_a(described_class) }
      it { is_expected.to have_attributes(expected_attributes) }
    end
  end

  describe '#client' do
    it 'returns the client from gateway' do
      expect(contract.client).to eql(gateway.client)
    end
  end

  describe '#signer' do
    it 'returns the signer from gateway' do
      expect(contract.signer).to eql(gateway.signer)
    end
  end

  describe '#gateway' do
    it 'returns the signer from gateway' do
      expect(contract.gateway).to eql(gateway)
    end
  end

  describe '#network_name' do
    it 'returns the network_name from the network' do
      expect(contract.network_name).to eql('testnet')
    end
  end

  describe '#evaluate' do
    pending 'TODO: implement'
  end

  describe '#evaluate_transaction' do
    pending 'TODO: implement'
  end

  describe '#submit' do
    pending 'TODO: implement'
  end

  describe '#submit_transaction' do
    pending 'TODO: implement'
  end

  describe '#new_proposal' do
    context 'when only transaction name is passed' do
      let(:proposal) { contract.new_proposal('some_transaction') }
      let(:proposed_transaction_expected_attributes) do
        [contract, 'some_transaction',
         {
           arguments: [],
           transient_data: {},
           endorsing_organizations: []
         }]
      end

      it 'returns a proposal' do
        expect(proposal).to be_a(Fabric::Proposal)
      end

      it 'initializes a new ProposedTransaction with arguments' do
        allow(Fabric::ProposedTransaction).to receive(:new)
          .with(*proposed_transaction_expected_attributes)

        proposal

        expect(Fabric::ProposedTransaction).to have_received(:new)
      end
    end

    context 'when arguments, transient_data, and endorsing_organizations are passed' do
      let(:proposal) do
        contract.new_proposal('some_transaction',
                              arguments: %w[two arguments],
                              transient_data: { transient_data: 'value' },
                              endorsing_organizations: %w[org1 org2])
      end
      let(:proposed_transaction_expected_attributes) do
        [contract, 'some_transaction',
         {
           arguments: %w[two arguments],
           transient_data: { transient_data: 'value' },
           endorsing_organizations: %w[org1 org2]
         }]
      end

      it 'returns a proposal' do
        expect(proposal).to be_a(Fabric::Proposal)
      end

      it 'initializes a new ProposedTransaction with arguments' do
        allow(Fabric::ProposedTransaction).to receive(:new)
          .with(*proposed_transaction_expected_attributes)

        proposal

        expect(Fabric::ProposedTransaction).to have_received(:new)
      end
    end
  end
end
