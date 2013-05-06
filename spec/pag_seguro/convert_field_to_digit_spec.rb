require 'spec_helper'

class MyObject
  attr_accessor :price, :amount
end

describe PagSeguro::ConvertFieldToDigit do
  subject{ MyObject.new }

  context "normal object" do
    context "with numeric price" do
      before{ subject.price = 10.02 }
      its(:price){ should == 10.02 }
      its(:price){ should be_an_instance_of(Float) }
    end

    context "with string price" do
      before{ subject.price = '10.02' }
      its(:price){ should == '10.02' }
      its(:price){ should be_an_instance_of(String) }
    end

    context "with decimal price" do
      before{ subject.price = BigDecimal.new('10.02') }
      its(:price){ should == BigDecimal.new('10.02') }
      its(:price){ should be_an_instance_of(BigDecimal) }
    end
  end

  context "object with price converted to digit" do
    before do
      MyObject.class_eval do
        extend PagSeguro::ConvertFieldToDigit
        attr_reader_as_digit :price, :amount
      end
    end

    context "with numeric attribute" do
      before{ subject.price, subject.amount = 10.2, 10 }
      its(:price){ should == '10.20' }
      its(:price){ should be_an_instance_of(String) }
      its(:amount){ should == '10.00' }
      its(:amount){ should be_an_instance_of(String) }
    end

    context "with string attribute" do
      before{ subject.price, subject.amount = '10.2', '10' }
      its(:price){ should == '10.20' }
      its(:price){ should be_an_instance_of(String) }
      its(:amount){ should == '10.00' }
      its(:amount){ should be_an_instance_of(String) }
    end

    context "with decimal attribute" do
      before{ subject.price, subject.amount = BigDecimal.new('10.02'), BigDecimal.new('10') }
      its(:price){ should == '10.02' }
      its(:price){ should be_an_instance_of(String) }
      its(:amount){ should == '10.00' }
      its(:amount){ should be_an_instance_of(String) }
    end

    context "with invalid conversion type" do
      before{ subject.price, subject.amount = '$ 10.00', nil }
      its(:price){ should == '$ 10.00' }
      its(:amount){ should == nil }
    end
  end
end
