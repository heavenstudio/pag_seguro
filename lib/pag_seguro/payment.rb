module PagSeguro
  class Payment
    include ActiveModel::Validations
        
    attr_accessor :id, :email, :token, :items, :sender, :shipping, :extra_amount, :redirect_url, :max_uses, :max_age
    
    validates_presence_of :email, :token
    validates_format_of :extra_amount, with: /^\d+\.\d{2}$/, message: " must be a decimal and have 2 digits after the dot", allow_blank: true
    validates_format_of :redirect_url, with: URI::regexp(%w(http https)), message: " must give a correct url for redirection", allow_blank: true
    validate :max_uses_number, :max_age_number
    
    def initialize(email = nil, token = nil, options = {})
      @email        = email unless email.nil?
      @token        = token unless token.nil?
      @id           = options[:id]
      @sender       = options[:sender] || Sender.new
      @shipping     = options[:shipping] || Shipping.new
      @items        = options[:items] || []
      @extra_amount = options[:extra_amount]
      @redirect_url = options[:redirect_url]
      @max_uses     = options[:max_uses]
      @max_age      = options[:max_age]
    end
    
    def checkout_xml
      xml_content = File.open( File.dirname(__FILE__) + "/checkout.xml.haml" ).read
      Haml::Engine.new(xml_content).render(nil, items: @items, payment: self, sender: @sender, shipping: @shipping)
    end
    
    def checkout_url_with_params
      "https://ws.pagseguro.uol.com.br/v2/checkout?email=#{@email}&token=#{@token}"
    end
    
    def checkout_payment_url
      "https://pagseguro.uol.com.br/v2/checkout/payment.html?code=#{code}"
    end
    
    def code
      response = send_checkout
      if response.code == 200
        Nokogiri::XML(response.body).css("checkout code").first.content
      elsif response.code == 401
        raise Errors::Unauthorized
      elsif response.code == 400
        raise Errors::InvalidData.new(response.body)
      else
        raise Errors::UnknownError.new(response)
      end
    end
    
    protected
      def max_uses_number
        errors.add(:max_uses, " must be an integer greater than 0") if @max_uses.present? && @max_uses.to_i <= 0
      end
      
      def max_age_number
        errors.add(:max_age, " must be an integer grater or equal to 30") if @max_age.present? && @max_age.to_i < 30
      end
            
      def send_checkout
        RestClient.post(checkout_url_with_params, checkout_xml, content_type: "application/xml"){|response, request, result| response }
      end
  end
end