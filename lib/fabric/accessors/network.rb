# frozen_string_literal: true

module Fabric
  module Accessors
    #
    # Add accessor methods to the given class.
    #
    # Usage: make sure the class has a network accessor method
    # and then `include Fabric::Accessors::Network`
    #
    module Network
      # @!visibility private
      def self.included(base)
        base.send :include, Fabric::Accessors::Gateway
      end

      # @!parse include Fabric::Accessors::Gateway

      #
      # Returns the gateway instance
      #
      # @return [Fabric::Gateway] gateway
      # @!parse attr_reader :gateway
      #
      def gateway
        network.gateway
      end

      #
      # Network name or the channel name or channel id
      #
      # @return [String] network name
      # @!parse attr_reader :network_name
      #
      def network_name
        network.name
      end
    end
  end
end
