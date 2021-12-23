# frozen_string_literal: true

require 'msp/identities_pb'
require 'base64'

# Adapted from:
# https://github.com/kirshin/hyperledger-fabric-sdk/blob/95a5a1a37001852312df25946e960a9ff149207e/lib/fabric/identity.rb

module Fabric
  #
  # @TODO missing tests
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

    attr_accessor :certificate, :mspid

    def initialize(opts = {})
      @crypto_suite = opts[:crypto_suite] || Fabric.crypto_suite

      @private_key = opts[:private_key] || @crypto_suite.generate_private_key
      @public_key = opts[:public_key] || @crypto_suite.restore_public_key(private_key)
      @certificate = opts[:certificate]
      @msp_id = opts[:msp_id]

      @address = @crypto_suite.address_from_public_key public_key
    end

    def generate_csr(attrs = [])
      @crypto_suite.generate_csr private_key, attrs
    end

    def sign(message)
      @crypto_suite.sign(private_key, message)
    end

    # TODO: Do we need this?
    def shared_secret_by(public_key)
      @crypto_suite.build_shared_key private_key, public_key
    end

    def serialize
      Msp::SerializedIdentity.new(mspid: mspid, id_bytes: pem_certificate).to_proto
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
