# frozen_string_literal: true

require 'fabric/constants'
require 'fabric/contract'
require 'fabric/client'
require 'fabric/ec_crypto_suite'
require 'fabric/gateway'
require 'fabric/identity'
require 'fabric/network'
require 'fabric/proposal'
require 'fabric/proposed_transaction'
require 'fabric/simple_proposal'
require 'fabric/version'

require 'gateway/gateway_pb'
require 'gateway/gateway_services_pb'

#
# Hyperledger Fabric Gateway SDK
#
module Fabric
  class Error < StandardError; end
  class InvalidArgument < Error; end
  class NotYetImplemented < Error; end

  #
  # CommitError
  #
  # @TODO: TEST ME!
  #
  class CommitError < Error
    attr_reader :code, :transaction_id

    def initialize(status)
      super("Transaction #{status.transaction_id} failed to commit with status code #{status.code} -" +
        Protos::TxValidationCode.lookup(status.code).to_s)
      @code = code
      @transaction_id = status.transaction_id
    end
  end

  def self.crypto_suite(opts = {})
    @crypto_suite ||= Fabric::ECCryptoSuite.new opts
  end
end
