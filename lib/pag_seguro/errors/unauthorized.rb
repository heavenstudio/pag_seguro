module PagSeguro
  module Errors
    class Unauthorized < Exception
      def initialize
        super("Credentials provided (e-mail and token) failed to authenticate")
      end
    end
  end
end
