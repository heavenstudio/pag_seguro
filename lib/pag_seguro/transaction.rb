# encoding: utf-8
require 'net/https'

module PagSeguro
  class Transaction
    attr_accessor :data

    PAGSEGURO_TRANSACTIONS_URL  = "https://ws.pagseguro.uol.com.br/v2/transactions"

    # possible status values
    PAGSEGURO_PROCESSING        = 1
    PAGSEGURO_IN_ANALYSIS       = 2
    PAGSEGURO_APPROVED          = 3
    PAGSEGURO_AVAILABLE         = 4
    PAGSEGURO_DISPUTED          = 5
    PAGSEGURO_RETURNED          = 6
    PAGSEGURO_CANCELLED         = 7

    # possible type values
    PAGSEGURO_PAYMENT           = 1
    PAGSEGURO_TRANSFER          = 2
    PAGSEGURO_ADDITION_OF_FUNDS = 3
    PAGSEGURO_CHARGE            = 4
    PAGSEGURO_BONUS             = 5

    def self.status_for(status_code)
      case status_code
      when PAGSEGURO_PROCESSING  then :processing
      when PAGSEGURO_IN_ANALYSIS then :in_analysis
      when PAGSEGURO_APPROVED    then :approved
      when PAGSEGURO_AVAILABLE   then :available
      when PAGSEGURO_DISPUTED    then :disputed
      when PAGSEGURO_RETURNED    then :returned
      when PAGSEGURO_CANCELLED   then :cancelled
      end
    end

    def initialize(transaction_xml)
      @data = transaction_data(transaction_xml)
    end

    def id
      @data.css("reference").first.content
    end
    alias :reference :id

    def gross_amount
      @data.css("grossAmount").first.content
    end

    def discount_amount
      @data.css("discountAmount").first.content
    end

    def fee_amount
      @data.css("feeAmount").first.content
    end

    def net_amount
      @data.css("netAmount").first.content
    end

    def extra_amount
      @data.css("extraAmount").first.content
    end

    def installment_count
      @data.css("installmentCount").first.content.to_i
    end

    def item_count
      @data.css("itemCount").first.content.to_i
    end

    def transaction_id
      @data.css("code").first.content
    end

    def date
      DateTime.iso8601( @data.css("date").first.content )
    end

    def items
      @data.css("items item").map do |i|
        Item.new id: parse_item(i, "id"),
                 description: parse_item(i, "description"),
                 quantity: parse_item(i, "quantity"),
                 amount: parse_item(i, "amount")
      end
    end

    def payment_method
      PaymentMethod.new code: parse_css("paymentMethod code"),
                        type: parse_css("paymentMethod type")
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

    def status
      @data.css("status").first.content.to_i
    end

    def type
      @data.css("type").first.content.to_i
    end

    def processing?
      PAGSEGURO_PROCESSING == status
    end

    def in_analysis?
      PAGSEGURO_IN_ANALYSIS == status
    end

    def approved?
      PAGSEGURO_APPROVED == status
    end

    def available?
      PAGSEGURO_AVAILABLE == status
    end

    def disputed?
      PAGSEGURO_DISPUTED == status
    end

    def returned?
      PAGSEGURO_RETURNED == status
    end

    def cancelled?
      PAGSEGURO_CANCELLED == status
    end

    def payment?
      PAGSEGURO_PAYMENT == type
    end

    def transfer?
      PAGSEGURO_TRANSFER == type
    end

    def addition_of_funds?
      PAGSEGURO_ADDITION_OF_FUNDS == type
    end

    def charge?
      PAGSEGURO_CHARGE == type
    end

    def bonus?
      PAGSEGURO_BONUS == type
    end

    protected
      def transaction_data(transaction_xml)
        transaction_xml.instance_of?(Nokogiri::XML::Element) ? transaction_xml : Nokogiri::XML(transaction_xml)
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
