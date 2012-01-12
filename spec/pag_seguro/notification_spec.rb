# encoding: utf-8

require 'spec_helper'
require_relative 'notification_data_mock'

describe PagSeguro::Notification do
  before do
    @notification = PagSeguro::Notification.new("mail", "token", "not_code")
  end
  
  it "should have an id" do
    @notification.id.should == "REF1234"
  end
  
  it "should have a transaction id" do
    @notification.transaction_id.should == "9E884542-81B3-4419-9A75-BCC6FB495EF1"
  end
  
  it "should be approved in this case" do
    @notification.should be_approved
  end
  
  it "should have a sender" do
    @sender = @notification.sender
    @sender.name.should == "José Comprador"
    @sender.email.should == "comprador@uol.com.br"
    @sender.phone_ddd.should == "11"
    @sender.phone_number == "56273440"
  end
  
  it "should have a shipping" do
    @shipping = @notification.shipping
    @shipping.type.should == "1"
    @shipping.cost.should == "21.50"
    @shipping.state.should == "SP"
    @shipping.city.should == "Sao Paulo"
    @shipping.postal_code.should == "01452002"
    @shipping.district.should == "Jardim Paulistano"
    @shipping.street.should == "Av. Brig. Faria Lima"
    @shipping.number.should == "1384"
    @shipping.complement.should == "5o andar"
  end
  
  it "should have items" do
    @items = @notification.items
    @items.size.should == 2

    @items[0].id.should == "0001"
    @items[0].description.should == "Notebook Prata"
    @items[0].quantity.should == "1"
    @items[0].amount.should == "24300.00"

    @items[1].id.should == "0002"
    @items[1].description.should == "Notebook Rosa"
    @items[1].quantity.should == "1"
    @items[1].amount.should == "25600.00"
  end
end