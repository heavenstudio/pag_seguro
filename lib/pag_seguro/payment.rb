module PagSeguro
  class Payment
    include ActiveModel::Validations
    extend PagSeguro::ConvertFieldToDigit

    attr_accessor :id, :email, :token, :items, :sender, :shipping,
                  :extra_amount, :redirect_url, :max_uses, :max_age,
                  :response, :pre_approval

    attr_reader_as_digit :extra_amount

    validates_presence_of :email, :token
    validates :extra_amount, pagseguro_decimal: true
    validates_format_of :redirect_url, with: URI::regexp(%w(http https)), message: " must give a correct url for redirection", allow_blank: true
    validate :max_uses_number, :max_age_number, :valid_pre_approval, :valid_items

    def initialize(email = nil, token = nil, options = {})
      @email        = email unless email.nil?
      @token        = token unless token.nil?
      @id           = options[:id]
      @sender       = options[:sender] || Sender.new
      @shipping     = options[:shipping]
      @items        = options[:items] || []
      @extra_amount = options[:extra_amount]
      @redirect_url = options[:redirect_url]
      @max_uses     = options[:max_uses]
      @max_age      = options[:max_age]
      @pre_approval = options[:pre_approval]
    end

    def self.checkout_payment_url(code)
      "https://pagseguro.uol.com.br/v2/checkout/payment.html?code=#{code}"
    end

    def checkout_xml
      xml_content = File.open( File.dirname(__FILE__) + "/checkout.xml.haml" ).read
      haml_engine = Haml::Engine.new(xml_content)

      haml_engine.render Object.new,
                         items: @items,
                         payment: self,
                         sender: @sender,
                         shipping: @shipping,
                         pre_approval: @pre_approval
    end

    def checkout_url_with_params
      "https://ws.pagseguro.uol.com.br/v2/checkout?email=#{@email}&token=#{@token}"
    end

    def checkout_payment_url
      self.class.checkout_payment_url(code)
    end

    def code
      response || parse_checkout_response
      parse_code
    end

    def date
      response || parse_checkout_response
      parse_date
    end

    def reset!
      @response = nil
    end

    protected
      def max_uses_number
        if @max_uses.present? && @max_uses.to_i <= 0
          errors.add(:max_uses, " must be an integer greater than 0")
        end
      end

      def max_age_number
        if @max_age.present? && @max_age.to_i < 30
          errors.add(:max_age, " must be an integer grater or equal to 30")
        end
      end

      def valid_pre_approval
        if pre_approval && !pre_approval.valid?
          errors.add(:pre_approval, " must be valid")
        end
      end

      def valid_items
        if items.blank? || !items.all?(&:valid?)
          errors.add(:items, " must be all valid")
        end
      end

      def send_checkout
        RestClient.post(checkout_url_with_params, checkout_xml, content_type: "application/xml"){|resp, request, result| resp }
      end

      def parse_checkout_response
        res = send_checkout
        raise Errors::Unauthorized if res.code == 401
        raise Errors::InvalidData.new(res.body) if res.code == 400
        raise Errors::UnknownError.new(res) if res.code != 200
        @response = res.body
      end

      def parse_date
        DateTime.iso8601(Nokogiri::XML(response.body).css("checkout date").first.content)
      end

      def parse_code
        Nokogiri::XML(response.body).css("checkout code").first.content
      end
  end
end
