module PagSeguro
  class Notification < Transaction

    def initialize(email, token, notification_code)
      raise "Needs a notification code" if notification_code.blank?
      raise "Needs an email" if email.blank?
      raise "Needs a token" if token.blank?
      @data = transaction_data(email, token, notification_code)
    end

    private
      def transaction_data(email, token, notification_code)
        notification_url = "#{PAGSEGURO_TRANSACTIONS_URL}/notifications/#{notification_code}"
        super RestClient.get notification_url, params: {email: email, token: token}
      end
  end
end
