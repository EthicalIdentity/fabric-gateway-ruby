module Fabric
  #
  # Utility class to create a unique transaction ID as transaction ID and signature header format.
  #
  class TransactionContext
    attr_reader :nonce, :creator

    # @return [string] Transaction ID as a hex string
    attr_reader :transaction_id

    # @return [Common::SignatureHeader] gRPC signature header message
    attr_reader :signature_header

    def initialize(signer)
      @nonce = signer.crypto_suite.generate_nonce
      @creator = signer.serialize

      salted_creator = @nonce + @creator
      @transaction_id = signer.crypto_suite.hexdigest(salted_creator)

      @signature_header = Common::SignatureHeader.new(creator: @creator, nonce: @nonce)
    end
  end
end
