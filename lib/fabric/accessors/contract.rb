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
      # @!visibility private
      def self.included(base)
        base.send :include, Fabric::Accessors::Network
      end

      # @!parse include Fabric::Accessors::Network
      # @!parse include Fabric::Accessors::Gateway

      #
      # Returns the network instance
      #
      # @return [Fabric::Network] network
      # @!parse attr_reader :network
      #
      def network
        contract.network
      end

      #
      # Returns the contract name
      #
      # @return [String] contract name
      # @!parse attr_reader :contract_name
      #
      def contract_name
        contract.contract_name
      end

      #
      # Returns the chaincode name
      #
      # @return [String] chaincode name
      # @!parse attr_reader :chaincode_name
      #
      def chaincode_name
        contract.chaincode_name
      end
    end
  end
end
