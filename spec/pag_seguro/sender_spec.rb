# encoding: UTF-8
require "spec_helper"

describe PagSeguro::Sender do
  context "instance" do
    before { @sender = PagSeguro::Sender.new }
    
    it "should have an email accessor" do
      @sender.should have_attribute_accessor(:email)
    end
    
    it "should have a name accessor" do
      @sender.should have_attribute_accessor(:name)
    end

    it "should have a phone_ddd accessor" do
      @sender.should have_attribute_accessor(:phone_ddd)
    end

    it "should have a phone_number" do
      @sender.should have_attribute_accessor(:phone_number)
    end
    
    it "should be able to initialize with all attributes" do
      sender = PagSeguro::Sender.new(:name => "Stefano Diem Benatti", :email => "stefano@heavenstudio.com.br", :phone_ddd => "11", :phone_number => "93430994")
      sender.name.should == "Stefano Diem Benatti"
      sender.email.should == "stefano@heavenstudio.com.br"
      sender.phone_ddd.should == "11"
      sender.phone_number.should == "93430994"
    end
    
    it "should tell valid e-mail appart" do
      @sender.email = "nothing"
      @sender.should_not be_a_valid_email
      @sender.email = ("a" * 50) + "waytoolongemail@mail.com"
      @sender.should_not be_a_valid_email
      @sender.email = "stefano@heavenstudio.com.br"
      @sender.should be_a_valid_email
    end
        
    it "should not show invalid e-mail" do
      @sender.email = "nothing"
      @sender.email.should be_nil
    end
    
    it "should not have a valid name unless name has two distict character sequences" do
      @sender.name = nil
      @sender.should_not be_a_valid_name
      @sender.name = "Joao"
      @sender.should_not be_a_valid_name
      @sender.name = "Joao Paulo"
      @sender.should be_a_valid_name
      @sender.name = "José Álvez"
      @sender.should be_a_valid_name
    end
    
    it "should not show invalid names" do
      @sender.name = "Joao"
      @sender.name.should be_nil
    end
    
    it "should crop the name if it is too big" do
      @sender.name = "a" * 50 + " b" * 10
      @sender.name.should == "a" * 50
    end
    
    it "should crop spaces (because double spaces raises errors on pagseguro)" do
      @sender.name = "Stefano   Benatti"
      @sender.name.should == "Stefano Benatti"
    end
    
    it "should not show invalid phone ddd's" do
      @sender.phone_ddd = "111"
      @sender.phone_ddd.should be_nil
    end
    
    it "should not show invalid phone number" do
      @sender.phone_number = "1234567"
      @sender.phone_number.should be_nil
    end
  end
end