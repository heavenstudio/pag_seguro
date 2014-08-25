require "spec_helper"

describe PagSeguro::Item do
  it { is_expected.to have_attribute_accessor(:id) }
  it { is_expected.to have_attribute_accessor(:description) }
  it { is_expected.to have_attribute_accessor(:amount) }
  it { is_expected.to have_attribute_accessor(:quantity) }
  it { is_expected.to have_attribute_accessor(:shipping_cost) }
  it { is_expected.to have_attribute_accessor(:weight) }

  it "should be valid with valid attributes" do
    expect(build(:item)).to be_valid
  end

  it { is_expected.to validate_presence_of :id }
  it { is_expected.to validate_presence_of :description }
  it { is_expected.to validate_presence_of :amount }

  it { is_expected.not_to allow_value(nil).for(:quantity) }
  it { is_expected.not_to allow_value(0).for(:quantity) }
  it { is_expected.not_to allow_value(1000).for(:quantity) }
  it { is_expected.to allow_value(1).for(:quantity) }
  it { is_expected.to allow_value(999).for(:quantity) }

  it { is_expected.not_to allow_value("10,50").for(:amount) }
  it { is_expected.not_to allow_value("R$ 10.50").for(:amount) }
  it { is_expected.not_to allow_value("-10.50").for(:amount) }
  it { is_expected.not_to allow_value("10.50\nanything").for(:amount) }
  it { is_expected.to allow_value("10.50").for(:amount) }
  it { is_expected.to allow_value(10).for(:amount) }
  it { is_expected.to allow_value(BigDecimal.new("10.5")).for(:amount) }

  it { is_expected.not_to allow_value("10,50").for(:shipping_cost) }
  it { is_expected.not_to allow_value("R$ 10.50").for(:shipping_cost) }
  it { is_expected.not_to allow_value("-10.50").for(:shipping_cost) }
  it { is_expected.not_to allow_value("10.50\nanything").for(:shipping_cost) }
  it { is_expected.to allow_value("10.50").for(:shipping_cost) }
  it { is_expected.to allow_value(10).for(:shipping_cost) }
  it { is_expected.to allow_value(BigDecimal.new("10.5")).for(:shipping_cost) }
  it { is_expected.to allow_value(nil).for(:shipping_cost) }

  it { is_expected.not_to allow_value("1000").for(:quantity) }
  it { is_expected.not_to allow_value("0").for(:quantity) }
  it { is_expected.not_to allow_value("-1").for(:quantity) }
  it { is_expected.to allow_value("1").for(:quantity) }

  it { is_expected.not_to allow_value("-10").for(:weight) }
  it { is_expected.not_to allow_value("10.5").for(:weight) }
  it { is_expected.not_to allow_value("10,5").for(:weight) }
  it { is_expected.to allow_value("3").for(:weight) }

  it "should trim description to 100 characters if it has more than 100 characters" do
    expect(PagSeguro::Item.new(description: "-" * 101).description.size).to eq(100)
  end
end
