module PagSeguro
  class Query < Transaction

    def initialize(email, token, transaction_code)
      raise "Needs a transaction code" if transaction_code.blank?
      raise "Needs an email" if email.blank?
      raise "Needs a token" if token.blank?
      @data = transaction_data(email, token, transaction_code)
    end

    def self.find(email, token, options={})
      url = Transaction::PAGSEGURO_TRANSACTIONS_URL
      url += "/abandoned" if options[:abandoned]

      transactions_data = Nokogiri::XML(RestClient.get url, params: search_params(email, token, options))
      transactions_data.css("transaction").map do |transaction_xml|
        Transaction.new(transaction_xml)
      end
    end

    def self.search_params(email, token, options={})
      params = {email: email, token: token}
      params[:initialDate], params[:finalDate] = parse_dates(options)
      params[:page] = options[:page] if options[:page]
      params[:maxPageResults] = options[:max_page_results] if options[:max_page_results]
      params
    end

    def self.parse_dates(options={})
      initial_date = (options[:initial_date] || Time.now - 1.day).to_time
      final_date   = (options[:final_date] || initial_date + 1.day).to_time

      raise "Invalid initial date. Must be bigger than 6 months ago" if initial_date < 6.months.ago
      raise "Invalid end date. Must be less than today" if final_date > Date.today.end_of_day
      raise "Invalid end date. Must be bigger than initial date" if final_date < initial_date
      raise "Invalid end date. Must not differ from initial date in more than 30 days" if (final_date.to_date - initial_date.to_date) > 30

      return initial_date.to_time.iso8601, final_date.to_time.iso8601
    end

    private
      def transaction_data(email, token, transaction_code)
        transaction_url = "#{PAGSEGURO_TRANSACTIONS_URL}/#{transaction_code}"
        super RestClient.get transaction_url, params: {email: email, token: token}
      end
  end
end
