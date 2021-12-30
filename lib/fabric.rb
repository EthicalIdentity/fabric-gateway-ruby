# frozen_string_literal: true

require 'gateway/gateway_pb'
require 'gateway/gateway_services_pb'

require 'fabric/entities/envelope'
require 'fabric/entities/identity'
require 'fabric/entities/proposal'
require 'fabric/entities/proposed_transaction'
require 'fabric/entities/status'
require 'fabric/entities/transaction'

require 'fabric/constants'
require 'fabric/contract'
require 'fabric/client'
require 'fabric/ec_crypto_suite'
require 'fabric/gateway'
require 'fabric/network'
require 'fabric/version'

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

    #
    # Creates a transaction commit error from the status
    #
    # @param [Fabric::Status] status transaction status
    #
    def initialize(status)
      super("Transaction #{status.transaction_id} failed to commit with status code #{status.code} -" +
        Status::TRANSACTION_STATUSES.key(status.code).to_s)
      @code = code
      @transaction_id = status.transaction_id
    end
  end

  def self.crypto_suite(opts = {})
    @crypto_suite ||= Fabric::ECCryptoSuite.new opts
  end
end
