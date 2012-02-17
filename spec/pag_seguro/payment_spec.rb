require 'spec_helper'

describe PagSeguro::Payment do
  context "instance" do
    context "accessors" do
      before { @payment = PagSeguro::Payment.new }
      
      it { @payment.should have_attribute_accessor(:id) }
      it { @payment.should have_attribute_accessor(:items) }
      it { @payment.should have_attribute_accessor(:sender) }
      it { @payment.should have_attribute_accessor(:shipping) }
      it { @payment.should have_attribute_accessor(:email) }
      it { @payment.should have_attribute_accessor(:token) }
      it { @payment.should have_attribute_accessor(:extra_amount) }
      it { @payment.should have_attribute_accessor(:redirect_url) }
      it { @payment.should have_attribute_accessor(:max_uses) }
      it { @payment.should have_attribute_accessor(:max_age) }
      it { @payment.should have_attribute_accessor(:response) }

      it "should respond to :code" do
        @payment.respond_to?(:code).should be_true
      end

      it "should respond to :date" do
        @payment.respond_to?(:date).should be_true
      end

      it "should have items" do
        @payment.items.should be_instance_of(Array)
        @payment.items.should be_empty
      end

      it "should have a sender" do
        @payment.sender.should be_instance_of(PagSeguro::Sender)
      end
    end
        
    it "should allow to set email and token initialization" do
      payment = PagSeguro::Payment.new("mymail", "mytoken")
      payment.email.should == "mymail"
      payment.token.should == "mytoken"
    end
    
    context "validation" do
      before { @payment = PagSeguro::Payment.new("mymail", "mytoken") }
      it "should be valid with valid attributes" do
        @payment.should be_valid
      end
      
      it "should not be valid without email" do
        @payment.email = nil
        @payment.should_not be_valid
      end

      it "should not be valid without token" do
        @payment.token = nil
        @payment.should_not be_valid
      end
      
      it "should not be valid with invalid extra amount format" do
        @payment.extra_amount = "10,50"
        @payment.should_not be_valid
        @payment.extra_amount = "R$ 10.50"
        @payment.should_not be_valid
        @payment.extra_amount = "10.50"
        @payment.should be_valid
      end
      
      it "should not allow invalid urls" do
        @payment.redirect_url = "httd://something"
        @payment.should_not be_valid
        @payment.redirect_url = "http://heavenstudio.com.br"
        @payment.should be_valid
      end
      
      it "should not allow an invalid number of uses" do
        @payment.max_uses = "0"
        @payment.should_not be_valid
        @payment.max_uses = "10"
        @payment.should be_valid
      end
      
      it "should not allow an invalid second time" do
        @payment.max_age = "29"
        @payment.should_not be_valid
        @payment.max_age = "30"
        @payment.should be_valid
      end
    end
  end
  
  context "checking out" do
    it "should have a checkout_url_with_params" do
      PagSeguro::Payment.new("mymail", "mytoken").checkout_url_with_params.should == 'https://ws.pagseguro.uol.com.br/v2/checkout?email=mymail&token=mytoken'
    end
    
    it "should generate a checkout url based on the received response" do
      payment = PagSeguro::Payment.new("mymail", "mytoken")
      payment.stub(:code).and_return("aabbcc")
      payment.checkout_payment_url.should == "https://pagseguro.uol.com.br/v2/checkout/payment.html?code=aabbcc"
    end
  end
end