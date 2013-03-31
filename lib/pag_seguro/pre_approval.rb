module PagSeguro
  class PreApproval
    attr_accessor :name, :details, :amount_per_payment, :period, :day_of_week, :day_of_month,
      :day_of_year, :initial_date, :final_date, :max_amount_per_period, :max_total_amount, :review_URL

    def initialize(options = {})
      @name = options[:name]
      @details = options[:details]
      @amount_per_payment = options[:amount_per_payment]
      @period = options[:period]
      @day_of_week = options[:day_of_week]
      @day_of_month = options[:day_of_month]
      @day_of_year = options[:day_of_year]
      @initial_date = options[:initial_date]
      @final_date = options[:final_date]
      @max_amount_per_period = options[:max_amount_per_period]
      @max_total_amount = options[:max_total_amount]
      @review_URL = options[:review_URL]
    end
  end
end