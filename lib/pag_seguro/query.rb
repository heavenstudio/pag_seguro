module PagSeguro
  class Query
    def self.query_transaction(email, token, transaction_code)
      url = Transaction::PAGSEGURO_TRANSACTIONS_URL + "/#{transaction_code}"
      params = {}
      params[:email] = email
      params[:token] = token

      Transaction.new(RestClient.get url, :params => params)
    end

    def self.query_transaction_history(email, token, initialDate, finalDate, page=1, maxPageResults=100, url=nil)
      transactions = []
      url ||= Transaction::PAGSEGURO_TRANSACTIONS_URL

      params = {}
      params[:email] = email
      params[:token] = token
      params[:initialDate] = initialDate
      params[:finalDate] = finalDate
      params[:page] = page
      params[:maxPageResults] = maxPageResults

      transactions_data = Nokogiri::XML(RestClient.get url, :params => params)

      transactions_data.css("transactions").each do |t|
        transactions << Transaction.new(t)
      end

      transactions
    end

    def self.query_abandoned_transactions(email, token, initialDate, finalDate, page, maxPageResults)
      url = Transaction::PAGSEGURO_TRANSACTIONS_URL + '/abandoned'
      self.query_transaction_history(email, token, initialDate, finalDate, page, maxPageResults, url)
    end
  end
end
