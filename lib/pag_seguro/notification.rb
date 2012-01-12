require 'net/https'

module PagSeguro
  class Notification
    attr_accessor :data
    PAGSEGURO_APPROVED = 3
    PAGSEGURO_AVAILABLE = 4
  
    def initialize(email = nil, token = nil, notification_code=nil)
      raise "Needs a notification code" if notification_code.blank?
      raise "Needs an email" if email.blank?
      raise "Needs a token" if token.blank?
      @data = Nokogiri::XML(notification_data(email, token, notification_code))
    end
      
    def status
      @data.css("status").first.content.to_i
    end
  
    def approved?
      PAGSEGURO_APPROVED == status
    end
    
    def available?
      PAGSEGURO_AVAILABLE == status
    end
  
    def id
      @data.css("reference").first.content
    end
  
    def items
      @data.css("items item").map do |i|
        Item.new(id: parse_item(i, "id"), description: parse_item(i, "description"), quantity: parse_item(i, "quantity"), amount: parse_item(i, "amount"))
      end
    end
    
    def sender
      sn = Sender.new
      sn.name = parse_css("sender name")
      sn.email = parse_css("sender email")
      sn.phone_ddd = parse_css("sender phone areaCode")
      sn.phone_number = parse_css("sender phone number")
      sn
    end
    
    def shipping
      sh = Shipping.new
      sh.type = parse_css("shipping type")
      sh.cost = parse_css("shipping cost")
      sh.state = parse_css("shipping address state")
      sh.city = parse_css("shipping address city")
      sh.postal_code = parse_css("shipping address postalCode")
      sh.district = parse_css("shipping address district")
      sh.street = parse_css("shipping address street")
      sh.number = parse_css("shipping address number")
      sh.complement = parse_css("shipping address complement")
      sh
    end
    
    private
      def notification_data(email, token, notification_code)
        RestClient.get("https://ws.pagseguro.uol.com.br/v2/transactions/notifications/#{notification_code}?email=#{email}&token=#{token}")
      end

      def parse_item(data, attribute)
        data.css(attribute).first.content
      end
      
      def parse_css(selector)
        value = @data.css(selector).first
        value.nil? ? nil : value.content
      end      
  end
end