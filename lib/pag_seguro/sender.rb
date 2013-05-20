module PagSeguro
  class Sender
    attr_accessor :name, :email, :phone_ddd, :phone_number

    def initialize(options = {})
      @name         = options[:name]
      @email        = options[:email]
      @phone_ddd    = options[:phone_ddd]
      @phone_number = options[:phone_number]
    end

    def email
      valid_email? ? @email : nil
    end

    def valid_email?
      @email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i && @email.size <= 60
    end

    def name
      return nil unless valid_name?
      @name.gsub(/ +/, " ")[0..49]
    end

    def valid_name?
      @name =~ /\S+ +\S+/
    end

    def phone_ddd
      @phone_ddd if @phone_ddd.to_s =~ /\A\d{2}\z/
    end

    def phone_number
      @phone_number if @phone_number.to_s =~/\A\d{8,9}\z/
    end
  end
end
