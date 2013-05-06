module PagSeguro
  class Item
    include ActiveModel::Validations
    extend PagSeguro::ConvertFieldToDigit

    attr_accessor :id, :description, :amount, :quantity, :shipping_cost, :weight
    attr_reader_as_digit :amount, :shipping_cost

    validates :id, presence: true
    validates :description, presence: true
    validates :amount, pagseguro_decimal: true, presence: true
    validates :shipping_cost, pagseguro_decimal: true
    validates :weight, numericality: { only_integer: true, greater_than: 0, allow_blank: true }
    validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 1000 }

    def initialize(attributes = {})
      @id = attributes[:id]
      @description = attributes[:description]
      @amount = attributes[:amount]
      @quantity = attributes[:quantity]
      @shipping_cost = attributes[:shipping_cost]
      @weight = attributes[:weight]
    end

    def description
      @description.present? && @description.size > 100 ? @description[0..99] : @description
    end
  end
end
