# encoding: utf-8
require 'spec_helper'

config = YAML.load_file(File.dirname(__FILE__) + "/config.yml")
EMAIL = config["email"]
TOKEN = config["token"]

describe "PagSeguro::Payment.code" do
  it "should send a request to pagseguro" do
    payment = PagSeguro::Payment.new(EMAIL, TOKEN)
    payment.items = [
      PagSeguro::Item.new(id: 25, description: "A Bic Pen", amount: "1.50",  quantity: "4", shipping_cost: "1.00",  weight: 10),
      PagSeguro::Item.new(id: 73, description: "A Book",    amount: "38.23", quantity: "1", shipping_cost: "12.00", weight: 300),
      PagSeguro::Item.new(id: 95, description: "A Towel",   amount: "69.35", quantity: "2", weight: 400),
      PagSeguro::Item.new(id: 17, description: "A pipe",    amount: "3.00",  quantity: "89")
    ]
    payment.sender = PagSeguro::Sender.new(name: "Stefano Diem Benatti", email: "stefano@heavenstudio.com.br", phone_ddd: "11", phone_number: "93430994")
    payment.shipping = PagSeguro::Shipping.new(type: PagSeguro::Shipping::SEDEX, state: "SP", city: "São Paulo", postal_code: "05363000", district: "Jd. PoliPoli", street: "Av. Otacilio Tomanik", number: "775", complement: "apto. 92")
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
end