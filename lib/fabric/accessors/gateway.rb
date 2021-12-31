# frozen_string_literal: true

module Fabric
  module Accessors
    #
    # Add accessor methods to the given class.
    #
    # Usage: make sure the class has a gateway accessor method
    # and then `include Fabric::Accessors::Gateway`
    #
    module Gateway
      def client
        gateway.client
      end

      def signer
        gateway.signer
      end
    end
  end
end
