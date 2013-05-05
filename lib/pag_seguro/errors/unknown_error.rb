module PagSeguro
  module Errors
    class UnknownError < Exception
      def initialize(response)
        super("Unknown response code (#{response.code}):\n#{response.body}")
      end
    end
  end
end
