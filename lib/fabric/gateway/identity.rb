require 'msp/identities_pb'
require 'base64'

module Fabric
  module Gateway
    class Identity
      attr_reader :private_key,
                  :public_key,
                  :address,
                  :crypto_suite

      attr_accessor :pem_certificate, :certificate, :mspid

      def initialize(opts = {})
        @crypto_suite = opts[:crypto_suite] || Fabric::Gateway.crypto_suite

        @private_key = opts[:private_key] || @crypto_suite.generate_private_key
        @public_key = opts[:public_key] || @crypto_suite.restore_public_key(private_key)
        @certificate = opts[:certificate]
        @pem_certificate = opts[:pem_certificate]
        @mspid = opts[:mspid]

        @address = @crypto_suite.address_from_public_key public_key
      end

      def generate_csr(attrs = [])
        @crypto_suite.generate_csr private_key, attrs
      end

      def sign(message)
        @crypto_suite.sign(private_key, message)
      end

      def shared_secret_by(public_key)
        @crypto_suite.build_shared_key private_key, public_key
      end

      def decoded_certificate
        Base64.strict_decode64 certificate
      end

      def serialize
        Msp::SerializedIdentity.new(mspid: mspid, id_bytes: pem_certificate).to_proto
      end
    end
  end
end
