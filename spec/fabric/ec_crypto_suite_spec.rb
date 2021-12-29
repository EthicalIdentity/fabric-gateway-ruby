# frozen_string_literal: true

RSpec.describe Fabric::ECCryptoSuite do
  describe '#openssl_pkey_from_public_key' do
    subject(:crypto_suite) { described_class.new }

    let(:random_public_key) do
      '04293ed1ea547c079f06f7bc6aa8adec39fd465ba839323a262fc7abab7714ba6' \
        'e680305dcfdf97043bfb1817a932cd7f4883d255b03ef303cf6651d765b9b3418'
    end

    it 'returns an OpenSSL::PKey::EC object' do
      expect(crypto_suite.openssl_pkey_from_public_key(random_public_key)).to be_a(OpenSSL::PKey::EC)
    end

    it 'generates a matching public key' do
      expect(crypto_suite.openssl_pkey_from_public_key(random_public_key).public_key.to_bn.to_s(16).downcase)
        .to eql(random_public_key)
    end
  end
end
