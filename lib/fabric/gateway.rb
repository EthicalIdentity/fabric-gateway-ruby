require "fabric/gateway/client"
require "fabric/gateway/constants"
require 'fabric/gateway/ec_crypto_suite'
require 'fabric/gateway/identity'
require "fabric/gateway/proposal"
require "fabric/gateway/version"


require "gateway/gateway_pb"
require "gateway/gateway_services_pb"

module Fabric
  module Gateway
    class Error < StandardError; end


    def self.crypto_suite(opts = {})
      @crypto_suite ||= Fabric::Gateway::ECCryptoSuite.new opts
    end
  end
end
