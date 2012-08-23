module PagSeguro
  class Item < Tableless
    attr_accessor :id, :description, :amount, :quantity, :shipping_cost, :weight
        
    validates_presence_of :id, :description, :amount, :quantity
    validates_format_of :amount, :with => /^\d+\.\d{2}$/, :message => " must be a decimal and have 2 digits after the dot"
    validates_format_of :shipping_cost, :with => /^\d+\.\d{2}$/, :message => " must be a decimal and have 2 digits after the dot"
    validates_format_of :weight, :with => /^\d+$/, :message => " must be an integer"
    validate :quantity_amount
    
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
    
    protected
      def quantity_amount
        errors.add(:quantity, " must be a number between 1 and 999") if @quantity.present? && (@quantity == "0" || @quantity.to_s !~ /^\d{1,3}$/)
      end
    end
end