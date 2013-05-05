# encoding: utf-8
require "spec_helper"

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

  its(:type){ should == PagSeguro::Shipping::UNIDENTIFIED }

  describe "instance" do
    subject{ build(:shipping) }

    it { should be_valid }
    its(:cost){ should == "12.13" }
    its(:postal_code){ should == "05363000" }

    context "with invalid postal_code" do
      subject{ build(:shipping, postal_code: 1234567) }
      its(:postal_code){ should be_blank }
    end

    context "with type 1" do
      subject{ build(:shipping, type: 1) }
      it { should be_pac }
    end

    context "with type 2" do
      subject{ build(:shipping, type: 2) }
      it { should be_sedex }
    end

    context "with type 3" do
      subject{ build(:shipping, type: 3) }
      it { should be_unidentified }
    end
  end
end
