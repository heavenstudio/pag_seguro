require "spec_helper"

describe PagSeguro::Item do
  it { should have_attribute_accessor(:id) }
  it { should have_attribute_accessor(:description) }
  it { should have_attribute_accessor(:amount) }
  it { should have_attribute_accessor(:quantity) }
  it { should have_attribute_accessor(:shipping_cost) }
  it { should have_attribute_accessor(:weight) }

  it "should be valid with valid attributes" do
    build(:item).should be_valid
  end

  it { should validate_presence_of :id }
  it { should validate_presence_of :description }
  it { should validate_presence_of :amount }

  it { should_not allow_value(nil).for(:quantity) }
  it { should_not allow_value(0).for(:quantity) }
  it { should_not allow_value(1000).for(:quantity) }
  it { should allow_value(1).for(:quantity) }
  it { should allow_value(999).for(:quantity) }

  it { should_not allow_value("10,50").for(:amount) }
  it { should_not allow_value("R$ 10.50").for(:amount) }
  it { should_not allow_value("-10.50").for(:amount) }
  it { should_not allow_value("10.50\nanything").for(:amount) }
  it { should allow_value("10.50").for(:amount) }
  it { should allow_value(10).for(:amount) }
  it { should allow_value(BigDecimal.new("10.5")).for(:amount) }

  it { should_not allow_value("10,50").for(:shipping_cost) }
  it { should_not allow_value("R$ 10.50").for(:shipping_cost) }
  it { should_not allow_value("-10.50").for(:shipping_cost) }
  it { should_not allow_value("10.50\nanything").for(:shipping_cost) }
  it { should allow_value("10.50").for(:shipping_cost) }
  it { should allow_value(10).for(:shipping_cost) }
  it { should allow_value(BigDecimal.new("10.5")).for(:shipping_cost) }
  it { should allow_value(nil).for(:shipping_cost) }

  it { should_not allow_value("1000").for(:quantity) }
  it { should_not allow_value("0").for(:quantity) }
  it { should_not allow_value("-1").for(:quantity) }
  it { should allow_value("1").for(:quantity) }

  it { should_not allow_value("-10").for(:weight) }
  it { should_not allow_value("10.5").for(:weight) }
  it { should_not allow_value("10,5").for(:weight) }
  it { should allow_value("3").for(:weight) }

  it "should trim description to 100 characters if it has more than 100 characters" do
    PagSeguro::Item.new(description: "-" * 101).description.size.should == 100
  end
end
