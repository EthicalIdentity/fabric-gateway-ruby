# frozen_string_literal: true

RSpec.describe Fabric::ECCryptoSuite do
  subject(:crypto_suite) { described_class.new }

  let(:private_key) { 'd62e76ab4a907d7634ada0d9709b4ed2bfc7c51c421127b7fc93c0141e461797' }
  let(:public_key) do
    '04a01f01fa942d2233a64aebe0b36c16ebdfd1c453ac5297591f20e2bfaba869e17e15f5f7367ee6f16121c64cac3ecdd517920a36f5145dc2a881ae9371873ac6'
  end
  let(:random_secret) { 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' }

  describe '#initialize' do
    context 'when no parameters are passed' do
      it 'utilizes default options' do
        expect(crypto_suite.key_size).to be(256)
        expect(crypto_suite.digest_algorithm).to eql('SHA256')
        expect(crypto_suite.curve).to eql('prime256v1')
        expect(crypto_suite.cipher).to eql('aes-256-cbc')
      end
    end

    context 'when options are passed' do
      subject(:crypto_suite) do
        described_class.new(
          {
            key_size: 384,
            digest_algorithm: 'SHA224',
            cipher: 'aes-128-cbc'
          }
        )
      end

      it 'utilizes options passed' do
        expect(crypto_suite.key_size).to be(384)
        expect(crypto_suite.digest_algorithm).to eql('SHA224')
        expect(crypto_suite.curve).to eql('secp384r1')
        expect(crypto_suite.cipher).to eql('aes-128-cbc')
      end
    end
  end

  describe '#sign' do
    it 'creates a valid signature' do
      signature = crypto_suite.sign(private_key, 'this is a test')
      expect(crypto_suite.verify(public_key, 'this is a test', signature)).to be(true)
    end
  end

  describe '#verify' do
    context 'when the signature is invalid' do
      it 'raises an error' do
        expect { crypto_suite.verify(public_key, 'this is a test', 'invalid') }.to raise_error(OpenSSL::ASN1::ASN1Error)
      end
    end

    context 'when the signature matches the key and the message' do
      it 'returns true' do
        signature = crypto_suite.sign(private_key, 'this is a test')
        expect(crypto_suite.verify(public_key, 'this is a test', signature)).to be(true)
      end
    end

    context 'when the signature does not match the key and the message' do
      it 'return false' do
        signature = crypto_suite.sign(private_key, 'this is a test')
        expect(crypto_suite.verify(public_key, 'this is not a test', signature)).to be(false)
      end
    end
  end

  describe '#generate_private_key' do
    it 'generates a valid EC private_key' do
      private_key = crypto_suite.generate_private_key
      expect(private_key).to be_a(String)

      public_key = crypto_suite.restore_public_key private_key

      group = OpenSSL::PKey::EC::Group.new(crypto_suite.curve)

      private_key_bn   = OpenSSL::BN.new(private_key, 16)
      public_key_bn    = OpenSSL::BN.new(public_key, 16)
      public_key_point = OpenSSL::PKey::EC::Point.new(group, public_key_bn)

      asn1 = OpenSSL::ASN1::Sequence(
        [
          OpenSSL::ASN1::Integer.new(1),
          OpenSSL::ASN1::OctetString(private_key_bn.to_s(2)),
          OpenSSL::ASN1::ObjectId(crypto_suite.curve, 0, :EXPLICIT),
          OpenSSL::ASN1::BitString(public_key_point.to_octet_string(:uncompressed), 1, :EXPLICIT)
        ]
      )

      pkey = OpenSSL::PKey::EC.new(asn1.to_der)

      expect(pkey.private?).to be(true)
      expect(pkey.private_key.to_s(16).downcase).to eql(private_key)
    end
  end

  describe '#generate_csr' do
    it 'generates a OpenSSL::X509::Request with the proper key' do
      req = crypto_suite.generate_csr(private_key)

      expect(req).to be_a(OpenSSL::X509::Request)
      expect(req.public_key.private_key.to_s(16).downcase).to eql(private_key)
    end
  end

  describe '#generate_nonce' do
    context 'when no parameters pass' do
      it 'generates a random 24 byte string' do
        expect(crypto_suite.generate_nonce.length).to be(24)
      end
    end

    context 'when passing byte length' do
      it 'generates a random byte string the size passed in' do
        expect(crypto_suite.generate_nonce(50).length).to be(50)
      end
    end
  end

  describe '#hexdigest' do
    it 'generates a hexdigest' do
      expect(crypto_suite.hexdigest('hello world')).to eql('b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9')
    end
  end

  describe '#digest' do
    it 'generates a digest' do
      digest = crypto_suite.digest('hello world')
      expected_digest = ['b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9'].pack('H*')
      expect(digest).to eql(expected_digest)
    end
  end

  describe '#encode_hex' do
    it 'converts bytes to hex' do
      expect(crypto_suite.encode_hex('a')).to eql('61')
    end
  end

  describe '#decode_hex' do
    it 'converts bytes to hex' do
      expect(crypto_suite.decode_hex('61')).to eql('a')
    end
  end

  describe '#restore_public_key' do
    it 'regenerates the public key from the private key' do
      expect(crypto_suite.restore_public_key(private_key)).to eql(public_key)
    end
  end

  describe '#address_from_public_key' do
    it 'returns the address from the public key' do
      expect(crypto_suite.address_from_public_key(public_key)).to eql('5de210d00aa3614d0e99ff84fe380bd34835f66e')
    end
  end

  # TODO: - it might be useful to test that the shared key can be properly utilized as well
  describe '#build_shared_key' do
    let(:random_public_key) do
      '04293ed1ea547c079f06f7bc6aa8adec39fd465ba839323a262fc7abab7714ba6' \
        'e680305dcfdf97043bfb1817a932cd7f4883d255b03ef303cf6651d765b9b3418'
    end

    it 'returns a shared key' do
      shared_key = crypto_suite.build_shared_key(private_key, random_public_key)
      expect(shared_key).to eql('f1388005817ef6c5f0e8d4f655b000c083a67926c991eaea3da4adf1fc20ceb5')
    end
  end

  describe '#decrypt' do
    context 'when data is nil' do
      it 'returns nil' do
        expect(crypto_suite.decrypt(random_secret, nil)).to be_nil
      end
    end
  end

  describe '#encrypt/#decrypt' do
    it 'properly able to encrypte and decrypt strings' do
      expect(crypto_suite.decrypt(random_secret,
                                  crypto_suite.encrypt(random_secret, 'this is a test'))).to eql('this is a test')
    end
  end

  describe '#pkey_from_private_key' do
    it 'converts a private key into a OpenSSL::PKey::EC' do
      pkey = crypto_suite.pkey_from_private_key(private_key)
      expect(pkey).to be_a(OpenSSL::PKey::EC)
      expect(pkey.private_key).to eql(OpenSSL::BN.new(private_key, 16))
    end
  end

  describe '#pem_from_private_key' do
    let(:expected_pem) do
      "-----BEGIN EC PRIVATE KEY-----\n" \
        "MHcCAQEEINYudqtKkH12NK2g2XCbTtK/x8UcQhEnt/yTwBQeRheXoAoGCCqGSM49\n" \
        "AwEHoUQDQgAEoB8B+pQtIjOmSuvgs2wW69/RxFOsUpdZHyDiv6uoaeF+FfX3Nn7m\n" \
        "8WEhxkysPs3VF5IKNvUUXcKoga6TcYc6xg==\n" \
        "-----END EC PRIVATE KEY-----\n"
    end

    it 'returns a pem from private key' do
      pem = crypto_suite.pem_from_private_key(private_key)
      expect(pem).to eql(expected_pem)
    end
  end

  describe '#public_key_from_x509_certificate' do
    let(:random_certificate) do
      "-----BEGIN CERTIFICATE-----\n" \
        "MIIBHjCBxaADAgECAgEBMAoGCCqGSM49BAMCMBcxFTATBgNVBAoTDERvY2tlciwg\n" \
        "SW5jLjAeFw0xMzA3MjUwMTEwMjRaFw0xNTA3MjUwMTEwMjRaMBcxFTATBgNVBAoT\n" \
        "DERvY2tlciwgSW5jLjBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABMolCWAO0iP7\n" \
        "tkX/KLjQ9CKeOoHYynBgfFcd1ZGoxcefmIbWjHx29eWI3xlhbjS6ssSxhrw1Kuh5\n" \
        "RrASfUCHD7SjAjAAMAoGCCqGSM49BAMCA0gAMEUCIQDRLQTSSeqjsxsb+q4exLSt\n" \
        "EM7f7/ymBzoUzbXU7wI9AgIgXCWaI++GkopGT8T2qV/3+NL0U+fYM0ZjSNSiwaK3\n" \
        "+kA=\n" \
        '-----END CERTIFICATE-----'
    end
    let(:random_certificate_public_key) do
      '04ca2509600ed223fbb645ff28b8d0f4229e3a81d8ca70607c571dd591a8c5c79f9886d68c7c76f5e588df19616e34bab2c4b186bc352ae87946b0127d40870fb4'
    end

    it 'returns public_key from x509 certificate' do
      public_key = crypto_suite.public_key_from_x509_certificate(random_certificate)
      expect(public_key).to eql(random_certificate_public_key)
    end
  end

  describe '#pkey_from_public_key' do
    let(:random_public_key) do
      '04293ed1ea547c079f06f7bc6aa8adec39fd465ba839323a262fc7abab7714ba6' \
        'e680305dcfdf97043bfb1817a932cd7f4883d255b03ef303cf6651d765b9b3418'
    end

    it 'returns an OpenSSL::PKey::EC object' do
      expect(crypto_suite.pkey_from_public_key(random_public_key)).to be_a(OpenSSL::PKey::EC)
    end

    it 'generates a matching public key' do
      expect(crypto_suite.pkey_from_public_key(random_public_key).public_key.to_bn.to_s(16).downcase)
        .to eql(random_public_key)
    end
  end
end
