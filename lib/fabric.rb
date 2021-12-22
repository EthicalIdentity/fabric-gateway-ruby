
require "fabric/constants"
require 'fabric/contract'
require 'fabric/client'
require 'fabric/ec_crypto_suite'
require 'fabric/gateway'
require 'fabric/identity'
require 'fabric/network'
require "fabric/proposal"
require "fabric/version"


require "gateway/gateway_pb"
require "gateway/gateway_services_pb"

module Fabric
  class Error < StandardError; end
  class InvalidArgument < Error; end

  def self.crypto_suite(opts = {})
    @crypto_suite ||= Fabric::ECCryptoSuite.new opts
  end
end
