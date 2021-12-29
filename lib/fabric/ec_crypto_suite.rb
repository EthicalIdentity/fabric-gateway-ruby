# frozen_string_literal: true

require 'openssl'

# Adapted from:
# https://github.com/kirshin/hyperledger-fabric-sdk/blob/95a5a1a37001852312df25946e960a9ff149207e/lib/fabric/crypto_suite.rb
module Fabric
  #
  # Elliptic-curve Crypto Suite using OpenSSL
  #
  # @TODO missing tests
  class ECCryptoSuite # rubocop:disable Metrics/ClassLength
    DEFAULT_KEY_SIZE = 256
    DEFAULT_DIGEST_ALGORITHM = 'SHA256'
    DEFAULT_AES_KEY_SIZE = 128

    EC_CURVES = { 256 => 'prime256v1', 384 => 'secp384r1' }.freeze

    CIPHER = 'aes-256-cbc'

    attr_reader :key_size, :digest_algorithm, :digest_instance, :curve, :cipher

    def initialize(opts = {})
      @key_size = opts[:key_size] || DEFAULT_KEY_SIZE
      @digest_algorithm = opts[:digest_algorithm] || DEFAULT_DIGEST_ALGORITHM
      @digest_instance = OpenSSL::Digest.new digest_algorithm
      @curve = EC_CURVES[key_size]
      @cipher = opts[:cipher] || CIPHER
    end

    def sign(private_key, message)
      digest = digest message
      key = pkey_from_private_key private_key
      signature = key.dsa_sign_asn1 digest
      sequence = OpenSSL::ASN1.decode signature
      sequence = prevent_malleability sequence, key.group.order

      sequence.to_der
    end

    def verify(public_key, message, signature)
      digest = digest message
      openssl_pkey = openssl_pkey_from_public_key public_key
      sequence = OpenSSL::ASN1.decode signature
      return false unless check_malleability sequence, openssl_pkey.group.order

      openssl_pkey.dsa_verify_asn1(digest, signature)
    end

    def generate_private_key
      key = OpenSSL::PKey::EC.new curve
      key.generate_key!

      key.private_key.to_s(16).downcase
    end

    def generate_csr(private_key, attrs = [])
      key = pkey_from_private_key private_key

      req = OpenSSL::X509::Request.new
      req.public_key = key
      req.subject = OpenSSL::X509::Name.new attrs
      req.sign key, @digest_instance

      req
    end

    def generate_nonce(length = 24)
      OpenSSL::Random.random_bytes length
    end

    def hexdigest(message)
      @digest_instance.hexdigest message
    end

    def digest(message)
      @digest_instance.digest message
    end

    def encode_hex(bytes)
      bytes.unpack1('H*')
    end

    def decode_hex(string)
      [string].pack('H*')
    end

    def restore_public_key(private_key)
      private_bn = OpenSSL::BN.new private_key, 16
      group = OpenSSL::PKey::EC::Group.new curve
      public_bn = group.generator.mul(private_bn).to_bn
      public_bn = OpenSSL::PKey::EC::Point.new(group, public_bn).to_bn

      public_bn.to_s(16).downcase
    end

    def address_from_public_key(public_key)
      bytes = decode_hex public_key
      address_bytes = digest(bytes[1..])[-20..]

      encode_hex address_bytes
    end

    def build_shared_key(private_key, public_key)
      pkey = pkey_from_private_key private_key
      public_bn = OpenSSL::BN.new public_key, 16
      group = OpenSSL::PKey::EC::Group.new curve
      public_point = OpenSSL::PKey::EC::Point.new group, public_bn

      encode_hex pkey.dh_compute_key(public_point)
    end

    def encrypt(secret, data)
      aes = OpenSSL::Cipher.new cipher
      aes.encrypt
      aes.key = decode_hex(secret)
      iv = aes.random_iv
      aes.iv = iv

      Base64.strict_encode64(iv + aes.update(data) + aes.final)
    end

    def decrypt(secret, data)
      return unless data

      encrypted_data = Base64.strict_decode64 data
      aes = OpenSSL::Cipher.new cipher
      aes.decrypt
      aes.key = decode_hex(secret)
      aes.iv = encrypted_data[0..15]
      encrypted_data = encrypted_data[16..]

      aes.update(encrypted_data) + aes.final
    end

    def pkey_pem_from_private_key(private_key)
      public_key = restore_public_key private_key
      key = OpenSSL::PKey::EC.new curve
      key.private_key = OpenSSL::BN.new private_key, 16
      key.public_key = OpenSSL::PKey::EC::Point.new key.group,
                                                    OpenSSL::BN.new(public_key, 16)

      pkey = OpenSSL::PKey::EC.new(key.public_key.group)
      pkey.public_key = key.public_key

      pkey.to_pem
    end

    def key_from_pem(pem)
      key = OpenSSL::PKey::EC.new(pem)
      key.private_key.to_s(16).downcase
    end

    def pkey_from_x509_certificate(certificate)
      cert = OpenSSL::X509::Certificate.new(certificate)
      cert.public_key.public_key.to_bn.to_s(16).downcase
    end

    def openssl_pkey_from_public_key(public_key)
      pkey = OpenSSL::PKey::EC.new curve
      pkey.public_key = OpenSSL::PKey::EC::Point.new(pkey.group, OpenSSL::BN.new(public_key, 16))

      pkey
    end

    private

    def pkey_from_private_key(private_key)
      public_key = restore_public_key private_key
      key = OpenSSL::PKey::EC.new curve
      key.private_key = OpenSSL::BN.new private_key, 16
      key.public_key = OpenSSL::PKey::EC::Point.new key.group,
                                                    OpenSSL::BN.new(public_key, 16)

      key
    end

    # barely understand this code - this link provides a good explanation:
    # http://coders-errand.com/malleability-ecdsa-signatures/
    def prevent_malleability(sequence, order)
      half_order = order >> 1

      if (half_key = sequence.value[1].value) > half_order
        sequence.value[1].value = order - half_key
      end

      sequence
    end

    # ported from python code, understanding extremely limited.
    # from what I gather, sequence.value[0] and sequence.value[1]
    # are the r and s values from the python implementation
    # https://github.com/hyperledger/fabric-sdk-py/blob/25209f61518873da68d28313582607c29b5bae7d/hfc/util/crypto/crypto.py#L259
    def check_malleability(sequence, order)
      half_order = order >> 1
      sequence.value[1].value <= half_order
    end
  end
end
