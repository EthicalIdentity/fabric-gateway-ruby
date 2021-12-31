# frozen_string_literal: true

module Fabric
  module Accessors
    #
    # Add accessor methods to the given class.
    #
    # Usage: make sure the class has a contract accessor method
    # and then `include Fabric::Accessors::Contract`
    #
    module Contract
      def self.included(base)
        base.send :include, Fabric::Accessors::Network
      end

      def network
        contract.network
      end

      def contract_name
        contract.contract_name
      end

      def chaincode_name
        contract.chaincode_name
      end
    end
  end
end
