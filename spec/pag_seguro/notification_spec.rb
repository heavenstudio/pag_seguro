# encoding: utf-8

require 'spec_helper'

describe PagSeguro::Notification do
  before do
    notification_xml_mock = File.open( File.expand_path( File.dirname(__FILE__) + '/../fixtures/notification.xml') )
    PagSeguro::Notification.any_instance.stub(:notification_data){ notification_xml_mock }
    @notification = PagSeguro::Notification.new("mail", "token", "not_code")
  end
  
  it "should have an id" do
    @notification.id.should == "REF1234"
  end
  
  it "should have a transaction id" do
    @notification.transaction_id.should == "9E884542-81B3-4419-9A75-BCC6FB495EF1"
  end
  
  it "should have a gross amount" do
    @notification.gross_amount.should be_present
    @notification.gross_amount.should match(/^\d+\.\d{2}$/)
  end

  it "should have a discount amount" do
    @notification.discount_amount.should be_present
    @notification.discount_amount.should match(/^\d+\.\d{2}$/)
  end

  it "should have a fee amount" do
    @notification.fee_amount.should be_present
    @notification.fee_amount.should match(/^\d+\.\d{2}$/)
  end
  
  it "should have a net amount" do
    @notification.net_amount.should be_present
    @notification.net_amount.should match(/^\d+\.\d{2}$/)
  end

  it "should have an extra amount" do
    @notification.extra_amount.should be_present
    @notification.extra_amount.should match(/^\d+\.\d{2}$/)
  end

  it "should have an installment count" do
    @notification.installment_count.should be_present
    @notification.installment_count.should be_an_integer
  end
  
  it "should have an item count" do
    @notification.item_count.should be_present
    @notification.item_count.should be_an_integer
    @notification.item_count.should == @notification.items.count
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
  
  it "should have a date" do
    @notification.date.should be_present
    @notification.date.should be_an_instance_of(DateTime)
    @notification.date.year.should == 2011
    @notification.date.month.should == 2
    @notification.date.day.should == 10
  end
  
  it "should have a shipping" do
    @shipping = @notification.shipping
    @shipping.type.should == 1
    @shipping.cost.should == "21.50"
    @shipping.state.should == "SP"
    @shipping.city.should == "Sao Paulo"
    @shipping.postal_code.should == "01452002"
    @shipping.district.should == "Jardim Paulistano"
    @shipping.street.should == "Av. Brig. Faria Lima"
    @shipping.number.should == "1384"
    @shipping.complement.should == "5o andar"
  end
  
  it "should have a payment method" do
    @payment_method = @notification.payment_method
    @payment_method.code.should == 101
    @payment_method.type.should == 1
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
  
  describe "status" do
    it "should have a status" do
      @notification.status.should == 3
    end
    
    it "should be processing if its status is 1" do
      @notification.stub(:status){ 1 }
      @notification.should be_processing
    end

    it "should be in analysis if its status is 2" do
      @notification.stub(:status){ 2 }
      @notification.should be_in_analysis
    end

    it "should be approved if its status is 3" do
      @notification.stub(:status){ 3 }
      @notification.should be_approved
    end

    it "should be available if its status is 4" do
      @notification.stub(:status){ 4 }
      @notification.should be_available
    end

    it "should be disputed if its status is 5" do
      @notification.stub(:status){ 5 }
      @notification.should be_disputed
    end

    it "should be disputed if its status is 5" do
      @notification.stub(:status){ 5 }
      @notification.should be_disputed
    end

    it "should be returned if its status is 6" do
      @notification.stub(:status){ 6 }
      @notification.should be_returned
    end

    it "should be cancelled if its status is 7" do
      @notification.stub(:status){ 7 }
      @notification.should be_cancelled
    end
  end
  
  describe "type" do
    it "should have a type" do
      @notification.type.should == 1
    end
    
    it "should be payment if type is 1" do
      @notification.stub(:type){ 1 }
      @notification.should be_payment
    end

    it "should be transfer if type is 2" do
      @notification.stub(:type){ 2 }
      @notification.should be_transfer
    end

    it "should be addition of funds if type is 3" do
      @notification.stub(:type){ 3 }
      @notification.should be_addition_of_funds
    end

    it "should be charge if type is 4" do
      @notification.stub(:type){ 4 }
      @notification.should be_charge
    end

    it "should be bonus if type is 5" do
      @notification.stub(:type){ 5 }
      @notification.should be_bonus
    end
  end
end