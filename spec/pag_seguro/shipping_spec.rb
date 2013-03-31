# encoding: utf-8
require "spec_helper"

valid_attributes = {
  type: PagSeguro::Shipping::SEDEX,
  state: "SP",
  city: "São Paulo",
  postal_code: "05363000",
  district: "Jd. PoliPoli",
  street: "Av. Otacilio Tomanik",
  number: "775",
  complement: "apto. 92",
  cost: "12.13"
}

describe PagSeguro::Shipping do
  let(:shipping){ PagSeguro::Shipping.new }

  it { should have_attribute_accessor(:type) }
  it { should have_attribute_accessor(:state) }
  it { should have_attribute_accessor(:city) }
  it { should have_attribute_accessor(:postal_code) }
  it { should have_attribute_accessor(:district) }
  it { should have_attribute_accessor(:street) }
  it { should have_attribute_accessor(:number) }
  it { should have_attribute_accessor(:complement) }
  it { should have_attribute_accessor(:cost) }

  describe "types" do
    it "should be pac if type is 1" do
      shipping.stub( :type ){ 1 }
      shipping.should be_pac
    end

    it "should be sedex if type is 2" do
      shipping.stub( :type ){ 2 }
      shipping.should be_sedex
    end

    it "should be unidentified if type is 3" do
      shipping.stub( :type ){ 3 }
      shipping.should be_unidentified
    end
  end

  describe "#cost" do
    it "should return the same specified cost" do
      PagSeguro::Shipping.new(valid_attributes).cost.should == "12.13"
    end
  end

  it "should be valid with valid_attributes" do
    PagSeguro::Shipping.new(valid_attributes).should be_valid
  end

  it "should not show postal code unless valid" do
    PagSeguro::Shipping.new(valid_attributes).postal_code.should == "05363000"
    PagSeguro::Shipping.new(valid_attributes.merge(postal_code: 1234567)).postal_code.should be_blank
  end
end