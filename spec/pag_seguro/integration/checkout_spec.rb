# encoding: utf-8
require 'spec_helper'

config = YAML.load_file(File.dirname(__FILE__) + "/config.yml")
EMAIL = config["email"]
TOKEN = config["token"]

def create_valid_payment
  payment = PagSeguro::Payment.new(EMAIL, TOKEN)
  payment.items = [
    PagSeguro::Item.new(id: 25, description: "A Bic Pen", amount: "1.50",  quantity: "4", shipping_cost: "1.00",  weight: 10),
    PagSeguro::Item.new(id: 73, description: "A Book",    amount: "38.23", quantity: "1", shipping_cost: "12.00", weight: 300),
    PagSeguro::Item.new(id: 95, description: "A Towel",   amount: "69.35", quantity: "2", weight: 400),
    PagSeguro::Item.new(id: 17, description: "A pipe",    amount: "3.00",  quantity: "89")
  ]
  payment.sender = PagSeguro::Sender.new(name: "Stefano Diem Benatti", email: "stefano@heavenstudio.com.br", phone_ddd: "11", phone_number: "93430994")
  payment.shipping = PagSeguro::Shipping.new(type: PagSeguro::Shipping::SEDEX, state: "SP", city: "São Paulo", postal_code: "05363000", district: "Jd. PoliPoli", street: "Av. Otacilio Tomanik", number: "775", complement: "apto. 92")
  payment
end

describe "PagSeguro::Payment.code" do
  it "should send a request to pagseguro" do
    payment = create_valid_payment
    payment.code.size.should == 32
  end
    
  it "should tell me when the email and token are invalid" do
    payment = PagSeguro::Payment.new("not_a_user@not_an_email.com", "NOTATOKEN7F048A09A8AEFDD1E5A7B91")
    lambda { payment.code }.should raise_error(PagSeguro::Errors::Unauthorized)
  end
    
  it "should list errors given by pagseguro" do
    payment = PagSeguro::Payment.new(EMAIL, TOKEN)
    lambda { payment.code }.should raise_error(PagSeguro::Errors::InvalidData)
  end
  
  it "should give a response code of 200 for the user pagseguro url" do
    payment = create_valid_payment
    RestClient.get(payment.checkout_payment_url).code.should == 200
  end
end

describe "PagSeguro::Payment.date" do
  it "should send a request to pagseguro" do
    payment = create_valid_payment
    payment.date.should match(/^\d{4}\-\d{2}\-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[-+]\d{2}:\d{2}$/)
  end
end

describe "PagSeguro::Payment parse_checkout_response" do
  before do
    @payment = create_valid_payment
    @payment.stub(:parse_code)
    @payment.stub(:parse_date)
    @payment.stub(:parse_checkout_response){ "some response" }
  end
  
  it "should not make a request to pagseguro more than once" do
    @payment.should_receive(:parse_checkout_response).exactly(1).times
    
    @payment.code
    @payment.code
    @payment.date
  end
  
  it "should be make more than one request to pag seguro if the payment is reset" do
    @payment.should_receive(:parse_checkout_response).exactly(2).times

    @payment.code
    @payment.reset!
    @payment.date
  end
end