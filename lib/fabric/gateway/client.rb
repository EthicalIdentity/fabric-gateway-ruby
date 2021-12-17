module Fabric
  module Gateway
    class Client
      attr_accessor :identity
      attr_accessor :connection

      def initialize(connection, identity) 
        self.identity = identity
        self.connection = connection
      end
    end
  end
end