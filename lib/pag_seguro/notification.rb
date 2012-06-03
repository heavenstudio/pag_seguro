module PagSeguro
  class Notification < Transaction
  
    def initialize(email = nil, token = nil, notification_code=nil)
      raise "Needs a notification code" if notification_code.blank?
      raise "Needs an email" if email.blank?
      raise "Needs a token" if token.blank?
      @data = transaction_data(email, token, notification_code)
    end
      
    private
      def transaction_data(email, token, notification_code)
        super(RestClient.get("#{PAGSEGURO_TRANSACTIONS_URL}/notifications/#{notification_code}?email=#{email}&token=#{token}"))
      end
  end
end
