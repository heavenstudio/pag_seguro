module PagSeguro
  module Errors
    class UnknownError
      def initialize(response)
        super("Unknown response code (#{response.code}):\n#{reponse.body}")
      end
    end
  end
end