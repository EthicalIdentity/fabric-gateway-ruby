# frozen_string_literal: true

RSpec.describe Fabric::Identity do
  describe '#new' do
    context 'when no params are passed' do
      subject(:identity) { described_class.new }

      it { is_expected.to be_a(described_class) }

      it 'uses the default crypto_suite' do
        expect(identity.crypto_suite).to eql(Fabric.crypto_suite)
      end

      it 'generates a new private key' do
        allow(Fabric.crypto_suite).to receive(:generate_private_key).and_call_original
        identity
        expect(Fabric.crypto_suite).to have_received(:generate_private_key)
      end

      it 'generates a public key from the private key' do
        allow(Fabric.crypto_suite).to receive(:restore_public_key).and_call_original
        identity
        expect(Fabric.crypto_suite).to have_received(:restore_public_key).with(identity.private_key)
      end

      # not sure if we should allow an identity without certificate,
      # because it is not usable for signing transactions. This can
      # potentially be extended to enroll a user and this would be
      # usable, but until then, an identity without a certificate is
      # useless.
      it 'does not generate a certificate' do
        expect(identity.certificate).to be_nil
      end

      it 'leaves msp_id nil' do
        expect(identity.msp_id).to be_nil
      end
    end

    context 'when valid params are passed' do
      subject(:identity) { described_class.new(private_key: u1_privkey, certificate: u1_cert) }

      let(:u1_privkey) { Fabric.crypto_suite.key_from_pem(File.read("#{RSPEC_ROOT}/fixtures/user1_privkey.pem")) }
      let(:u1_cert) { File.read("#{RSPEC_ROOT}/fixtures/user1_cert.pem") }

      it 'sets private_key' do
        expect(identity.private_key).to eql('1d68b4efe425473ca8328c82a1cd3522d9dcb429dba612f619bfa827d9734699')
      end

      it 'sets public_key' do
        expect(identity.public_key).to eql('04f8aecc56ff47ac1545b3bdfc86f7c170cd12aa75284e677c493b4b2ebac92f9826f9aa4068341e98e094916b794b7c3a7133625623f714a90da7ce342a7ffaa8')
      end

      it 'sets certificate' do
        expect(identity.certificate).to eql(u1_cert)
      end
    end

    context 'when mismatch key and certificate' do
      subject(:identity) { described_class.new(private_key: u1_privkey, certificate: u2_cert) }

      let(:u1_privkey) { Fabric.crypto_suite.key_from_pem(File.read("#{RSPEC_ROOT}/fixtures/user1_privkey.pem")) }
      let(:u2_cert) { File.read("#{RSPEC_ROOT}/fixtures/user2_cert.pem") }

      it 'raises an error' do
        expect do
          identity
        end.to raise_error(Fabric::Error).with_message('Key mismatch (public_key or certificate) for identity')
      end
    end
  end

  describe '#generate_csr' do
    pending 'TODO: implement in identity enrollment process'
  end

  describe '#sign' do
    subject(:identity) { described_class.new(private_key: u1_privkey, certificate: u1_cert) }

    let(:u1_privkey) { Fabric.crypto_suite.key_from_pem(File.read("#{RSPEC_ROOT}/fixtures/user1_privkey.pem")) }
    let(:u1_cert) { File.read("#{RSPEC_ROOT}/fixtures/user1_cert.pem") }

    it 'signs a message' do
      signature = identity.sign('hello world')
      expect(Fabric.crypto_suite.verify(identity.public_key, 'hello world', signature)).to be(true)
    end
  end

  describe '#digest' do
    subject(:digest) { described_class.new.digest('hello world') }

    let(:expected_digest) { 'b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9' }

    it { expect(Digest.hexencode(digest)).to eql(expected_digest) }
  end

  describe '#as_proto' do
    subject(:identity) { described_class.new(private_key: u1_privkey, certificate: u1_cert, msp_id: 'org1test') }

    let(:u1_privkey) { Fabric.crypto_suite.key_from_pem(File.read("#{RSPEC_ROOT}/fixtures/user1_privkey.pem")) }
    let(:u1_cert) { File.read("#{RSPEC_ROOT}/fixtures/user1_cert.pem") }

    it 'returns a protobuf Msp::SerializedIdentity' do
      expect(identity.as_proto).to be_a(Msp::SerializedIdentity)
    end

    it 'sets the attributes' do
      expect(identity.as_proto).to have_attributes({ mspid: 'org1test', id_bytes: u1_cert })
    end
  end

  describe '#to_proto' do
    subject(:identity) { described_class.new(private_key: u1_privkey, certificate: u1_cert, msp_id: 'org1test') }

    let(:u1_privkey) { Fabric.crypto_suite.key_from_pem(File.read("#{RSPEC_ROOT}/fixtures/user1_privkey.pem")) }
    let(:u1_cert) { File.read("#{RSPEC_ROOT}/fixtures/user1_cert.pem") }

    let(:u1_serialized_identity) { File.read "#{RSPEC_ROOT}/fixtures/user1_serialized_identity.pb" }

    it 'returns a serialized protobuf binary string' do
      expect(identity.to_proto.force_encoding('BINARY')).to eq(u1_serialized_identity.force_encoding('BINARY'))
    end
  end

  describe '#new_gateway' do
    subject(:identity) { described_class.new }

    context 'when valid client is passed' do
      let(:client) { build(:simple_client) }
      let(:gateway) { identity.new_gateway(client) }

      it 'creates a gateway' do
        expect(gateway).to be_a(Fabric::Gateway)
      end

      it 'assigns the proper attributes' do
        expect(gateway).to have_attributes(client: client, signer: identity)
      end
    end
  end
end
