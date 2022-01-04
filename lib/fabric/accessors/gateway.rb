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
      #
      # Returns the client instance
      #
      # @return [Fabric::Client] client
      # @!parse attr_reader :client
      #
      def client
        gateway.client
      end

      #
      # Returns the signer identity instance
      #
      # @return [Fabric::Identity] signer
      # @!parse attr_reader :signer
      #
      def signer
        gateway.signer
      end
    end
  end
end
