module PagSeguro
  class Query < Transaction
  
    def initialize(email = nil, token = nil, transaction_code=nil)
      raise "Needs a transaction code" if transaction_code.blank?
      raise "Needs an email" if email.blank?
      raise "Needs a token" if token.blank?
      @data = transaction_data(email, token, transaction_code)
    end
      
    def self.find(email = nil, token = nil, options={})
      raise "Invalid options" unless options.kind_of? Hash
      raise "Needs an email" if email.blank?
      raise "Needs a token" if token.blank?

      # pagseguro ignores timezone and use -03:00 by default
      initial_date     = options[:initial_date] || (Time.now.utc - 86400 - (3600*3)).strftime("%Y-%m-%dT%H:%M:%S.%L-03:00")
      final_date       = options[:final_date] || (Time.now.utc - (3600*3)).strftime("%Y-%m-%dT%H:%M:%S.%L-03:00")
      page             = options[:page] || 1
      max_page_results = options[:max_page_results] || 100
      search_url = "#{Transaction::PAGSEGURO_TRANSACTIONS_URL}?email=#{email}&token=#{token}&initialDate=#{initial_date}&finalDate=#{final_date}&page=#{page}&maxPageResults=#{max_page_results}"

      Nokogiri::XML(RestClient.get(search_url)).css("transaction").map do |transaction_xml|
        Transaction.new(transaction_xml)
      end
    end
 
    private
      def transaction_data(email, token, transaction_code)
        super(RestClient.get("#{PAGSEGURO_TRANSACTIONS_URL}/#{transaction_code}?email=#{email}&token=#{token}"))
      end
  end
end
