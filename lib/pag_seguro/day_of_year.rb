module PagSeguro
  module Error
    class InvalidDayOfYear < Exception
      def initialize(date_of_year)
        super("DateOfYear should be a valid date: (month: #{date_of_year.month}, day: #{date_of_year.day})")
      end
    end
  end

  class DayOfYear
    include Comparable
    attr_accessor :day, :month

    def initialize(options = {})
      @day = options[:day]
      @month = options[:month]
    end

    def to_s
      raise Error::InvalidDayOfYear.new(self) unless valid?
      "#{"%02d" % @month}-#{"%02d" % @day}"
    end

    # very simple date validation, just to smoke test possible
    # errors of switching day with month
    def valid?
      @day < 31 && @month < 12
    end

    def <=>(other_day_of_the_year)
      return  1 if @month > other_day_of_the_year.month
      return -1 if @month < other_day_of_the_year.month
      @day <=> other_day_of_the_year.day
    end
  end
end
