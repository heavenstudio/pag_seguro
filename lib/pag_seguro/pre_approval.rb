module PagSeguro
  class PreApproval
    include ActiveModel::Validations
    extend PagSeguro::ConvertFieldToDigit

    PERIOD_TYPES = %w(weekly monthly bimonthly trimonthly semiannually yearly)
    DAYS_OF_WEEK = %w(monday tuesday wednesday thursday friday saturday sunday)
    DATE_RANGE = 17856.hours

    attr_accessor :name, :details, :amount_per_payment, :period,
                  :day_of_week, :day_of_month, :day_of_year, :initial_date,
                  :final_date, :max_amount_per_period, :max_total_amount,
                  :review_URL

    attr_reader_as_digit :amount_per_payment, :max_amount_per_period, :max_total_amount

    validates_presence_of :name, :period, :final_date, :max_total_amount, :max_amount_per_period
    validates_inclusion_of :period, in: PERIOD_TYPES
    validates_inclusion_of :day_of_week, in: DAYS_OF_WEEK, if: :weekly?
    validates_inclusion_of :day_of_month, in: (1..28), if: :monthly?
    validates_presence_of :day_of_year, if: :yearly?
    validates_format_of :day_of_year, with: /\A\d{2}-\d{2}\z/, if: :yearly?
    validate :initial_date_range, :final_date_range
    validates :max_amount_per_period, pagseguro_decimal: true
    validates :max_total_amount, pagseguro_decimal: true

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

    def period
      @period.to_s.downcase
    end

    def day_of_week
      @day_of_week.to_s.downcase
    end

    def day_of_year
      @day_of_year.to_s
    end

    def initial_date
      @initial_date.to_datetime if @initial_date.present?
    end

    def final_date
      @final_date.to_datetime if @final_date.present?
    end

    def weekly?
      period == 'weekly'
    end

    def monthly?
      %w(monthly bimonthly trimonthly).include? period
    end

    def yearly?
      period == 'yearly'
    end

    protected
      def initial_date_range
        return unless initial_date
        errors.add(:initial_date) if initial_date < Time.now - 5.minutes
        errors.add(:initial_date) if initial_date > DATE_RANGE.from_now
      end

      def final_date_range
        return unless final_date
        errors.add(:final_date) if final_date < (initial_date || Time.now) - 5.minutes
        errors.add(:final_date) if final_date > (initial_date || Time.now) + DATE_RANGE
      end
  end
end
