module PagSeguro
  class Query < Transaction
  
    def initialize(email = nil, token = nil, transaction_code=nil)
      raise "Needs a transaction code" if transaction_code.blank?
      raise "Needs an email" if email.blank?
      raise "Needs a token" if token.blank?
      @data = transaction_data(email, token, transaction_code)
    end
      
    private
      def transaction_data(email, token, transaction_code)
        super(RestClient.get("#{PAGSEGURO_TRANSACTIONS_URL}/#{transaction_code}?email=#{email}&token=#{token}"))
      end
  end
end
