module Fabric
  module Accessors
    #
    # Add accessor methods to the given class.
    #
    # Usage: make sure the class has a network accessor method
    # and then `include Fabric::Accessors::Network`
    #
    module Network
      def self.included(base)
        base.send :include, Fabric::Accessors::Gateway
      end

      def gateway
        network.gateway
      end

      def network_name
        network.name
      end
    end
  end
end
