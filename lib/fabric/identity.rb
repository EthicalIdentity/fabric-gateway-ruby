# frozen_string_literal: true

require 'msp/identities_pb'
require 'base64'

# Adapted from:
# https://github.com/kirshin/hyperledger-fabric-sdk/blob/95a5a1a37001852312df25946e960a9ff149207e/lib/fabric/identity.rb

module Fabric
  #
  # @attr_reader [String] private_key raw private key in hex format
  # @attr_reader [String] public_key raw public key in hex format
  # @attr_reader [String] certificate raw certificate in pem format
  # @attr_reader [String] msp_id MSP (Membership Service Provider) Identifier
  #
  class Identity
    attr_reader :private_key,
                :public_key,
                :address, # TODO: possibly unnecessary
                :crypto_suite

    attr_accessor :certificate, :msp_id

    def initialize(private_key: nil, public_key: nil, certificate: nil, msp_id: nil, crypto_suite: nil)
      @crypto_suite = crypto_suite || Fabric.crypto_suite

      @private_key = private_key || @crypto_suite.generate_private_key
      @public_key = public_key || @crypto_suite.restore_public_key(@private_key)
      @certificate = certificate
      @msp_id = msp_id

      @address = @crypto_suite.address_from_public_key @public_key

      return unless @certificate

      raise Fabric::Error, 'Key mismatch (public_key or certificate) for identity' unless validate_key_integrity
    end

    #
    # Validates that the private_key, public_key, and certificate are valid and match
    #
    # @return [boolean] true if valid, false otherwise
    #
    def validate_key_integrity
      cert_pubkey = @crypto_suite.pkey_from_x509_certificate(certificate)
      priv_pubkey = @crypto_suite.restore_public_key(@private_key)

      @public_key == cert_pubkey && @public_key == priv_pubkey
    end

    def generate_csr(attrs = [])
      @crypto_suite.generate_csr private_key, attrs
    end

    def sign(message)
      @crypto_suite.sign(private_key, message)
    end

    def digest(message)
      @crypto_suite.digest message
    end

    # TODO: Do we need this?
    def shared_secret_by(public_key)
      @crypto_suite.build_shared_key private_key, public_key
    end

    def as_proto
      @serialized_identity ||= Msp::SerializedIdentity.new(mspid: msp_id, id_bytes: certificate)
    end

    def to_proto
      @serialized_identity ||= Msp::SerializedIdentity.new(mspid: msp_id, id_bytes: certificate).to_proto
    end

    #
    # Creates a new gateway passing in the current identity
    #
    # @param [Gateway::Gateway::Stub] connection <description>
    #
    # @return [Fabric::Gateway] <description>
    #
    def new_gateway(client)
      Fabric::Gateway.new(self, client)
    end
  end
end
