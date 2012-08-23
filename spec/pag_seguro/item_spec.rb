require "spec_helper"

valid_attributes = {
  :id => 1,
  :description => "descrevendo um item",
  :amount => "100.50",
  :quantity => 1,
  :shipping_cost => "10.50",
  :weight => 300
}

describe PagSeguro::Item do
  context "instance" do
    before { @item = PagSeguro::Item.new }

    it { @item.should have_attribute_accessor(:id) }
    it { @item.should have_attribute_accessor(:description) }
    it { @item.should have_attribute_accessor(:amount) }
    it { @item.should have_attribute_accessor(:quantity) }
    it { @item.should have_attribute_accessor(:shipping_cost) }
    it { @item.should have_attribute_accessor(:weight) }

    it "should be valid with valid attributes" do
      PagSeguro::Item.new(valid_attributes).should be_valid
    end

    it "should not be valid without an id" do
      PagSeguro::Item.new(valid_attributes.except(:id)).should_not be_valid
    end

    it "should not be valid without a description" do
      PagSeguro::Item.new(valid_attributes.except(:description)).should_not be_valid
    end

    it "should trim description to 100 characters if it has more than 100 characters" do
      item = PagSeguro::Item.new(valid_attributes)
      item.description = "-" * 100
      item.description.size.should == 100
      item.should be_valid
      item.description = "-" * 101
      item.description.size.should == 100
      item.should be_valid
    end

    it "should not be valid without an amount" do
      PagSeguro::Item.new(valid_attributes.except(:amount)).should_not be_valid
    end

    it "should not allow invalid amount formats" do
      PagSeguro::Item.new(valid_attributes.merge(:amount => "10")).should_not be_valid
      PagSeguro::Item.new(valid_attributes.merge(:amount => "10,50")).should_not be_valid
      PagSeguro::Item.new(valid_attributes.merge(:amount => "R$ 10.50")).should_not be_valid
      PagSeguro::Item.new(valid_attributes.merge(:amount => "-10.50")).should_not be_valid
    end

    it "should not be valid without a quantity" do
      PagSeguro::Item.new(valid_attributes.except(:quantity)).should_not be_valid
    end

    it "should not allow invalid quantities" do
      PagSeguro::Item.new(valid_attributes.merge(:quantity => "1000")).should_not be_valid
      PagSeguro::Item.new(valid_attributes.merge(:quantity => "0")).should_not be_valid
      PagSeguro::Item.new(valid_attributes.merge(:quantity => "-1")).should_not be_valid
    end

    it "should not allow invalid shipping_cost formats" do
      PagSeguro::Item.new(valid_attributes.merge(:shipping_cost => "10")).should_not be_valid
      PagSeguro::Item.new(valid_attributes.merge(:shipping_cost => "10,50")).should_not be_valid
      PagSeguro::Item.new(valid_attributes.merge(:shipping_cost => "R$ 10.50")).should_not be_valid
      PagSeguro::Item.new(valid_attributes.merge(:shipping_cost => "-10.50")).should_not be_valid
    end
    
    it "should not allow non integer values for weight" do
      PagSeguro::Item.new(valid_attributes.merge(:weight => "-10")).should_not be_valid
      PagSeguro::Item.new(valid_attributes.merge(:weight => "10.5")).should_not be_valid
      PagSeguro::Item.new(valid_attributes.merge(:weight => "10,5")).should_not be_valid
    end
  end
end