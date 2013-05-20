# encoding: UTF-8
shared_examples_for "a transaction" do
  let(:transaction_xml){ File.open( File.expand_path( File.dirname(__FILE__) + '/../fixtures/transaction.xml') ) }
  let(:transaction_data){ Nokogiri::XML(transaction_xml) }
  
  it "should have an id" do
    transaction.id.should == "REF1234"
  end

  it "should have a reference" do
    transaction.reference.should == "REF1234"
  end
  
  it "should have a transaction id" do
    transaction.transaction_id.should == "9E884542-81B3-4419-9A75-BCC6FB495EF1"
  end
  
  it "should have a gross amount" do
    transaction.gross_amount.should be_present
    transaction.gross_amount.should match(/^\d+\.\d{2}$/)
  end

  it "should have a discount amount" do
    transaction.discount_amount.should be_present
    transaction.discount_amount.should match(/^\d+\.\d{2}$/)
  end

  it "should have a fee amount" do
    transaction.fee_amount.should be_present
    transaction.fee_amount.should match(/^\d+\.\d{2}$/)
  end
  
  it "should have a net amount" do
    transaction.net_amount.should be_present
    transaction.net_amount.should match(/^\d+\.\d{2}$/)
  end

  it "should have an extra amount" do
    transaction.extra_amount.should be_present
    transaction.extra_amount.should match(/^\d+\.\d{2}$/)
  end

  it "should have an installment count" do
    transaction.installment_count.should be_present
    transaction.installment_count.should be_an_integer
  end
  
  it "should have an item count" do
    transaction.item_count.should be_present
    transaction.item_count.should be_an_integer
    transaction.item_count.should == transaction.items.count
  end
  
  it "should be approved in this case" do
    transaction.should be_approved
  end
  
  it "should have a sender" do
    @sender = transaction.sender
    @sender.name.should == "José Comprador"
    @sender.email.should == "comprador@uol.com.br"
    @sender.phone_ddd.should == "11"
    @sender.phone_number == "56273440"
  end
  
  it "should have a date" do
    transaction.date.should be_present
    transaction.date.should be_an_instance_of(DateTime)
    transaction.date.year.should == 2011
    transaction.date.month.should == 2
    transaction.date.day.should == 10
  end
  
  it "should have a shipping" do
    @shipping = transaction.shipping
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
    @payment_method = transaction.payment_method
    @payment_method.code.should == 101
    @payment_method.type.should == 1
  end
  
  it "should have items" do
    @items = transaction.items
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
      transaction.status.should == 3
    end
    
    it "should be processing if its status is 1" do
      transaction.stub(:status){ 1 }
      transaction.should be_processing
    end

    it "should be in analysis if its status is 2" do
      transaction.stub(:status){ 2 }
      transaction.should be_in_analysis
    end

    it "should be approved if its status is 3" do
      transaction.stub(:status){ 3 }
      transaction.should be_approved
    end

    it "should be available if its status is 4" do
      transaction.stub(:status){ 4 }
      transaction.should be_available
    end

    it "should be disputed if its status is 5" do
      transaction.stub(:status){ 5 }
      transaction.should be_disputed
    end

    it "should be disputed if its status is 5" do
      transaction.stub(:status){ 5 }
      transaction.should be_disputed
    end

    it "should be returned if its status is 6" do
      transaction.stub(:status){ 6 }
      transaction.should be_returned
    end

    it "should be cancelled if its status is 7" do
      transaction.stub(:status){ 7 }
      transaction.should be_cancelled
    end
  end
  
  describe "type" do
    it "should have a type" do
      transaction.type.should == 1
    end
    
    it "should be payment if type is 1" do
      transaction.stub(:type){ 1 }
      transaction.should be_payment
    end

    it "should be transfer if type is 2" do
      transaction.stub(:type){ 2 }
      transaction.should be_transfer
    end

    it "should be addition of funds if type is 3" do
      transaction.stub(:type){ 3 }
      transaction.should be_addition_of_funds
    end

    it "should be charge if type is 4" do
      transaction.stub(:type){ 4 }
      transaction.should be_charge
    end

    it "should be bonus if type is 5" do
      transaction.stub(:type){ 5 }
      transaction.should be_bonus
    end
  end

  describe "::status_for" do
    it "should return :processing for 1" do
      subject.status_for(1).should == :processing
    end

    it "should return :in_analysis for 2" do
      subject.status_for(2).should == :in_analysis
    end

    it "should return :approved for 3" do
      subject.status_for(3).should == :approved
    end

    it "should return :available for 4" do
      subject.status_for(4).should == :available
    end

    it "should return :disputed for 5" do
      subject.status_for(5).should == :disputed
    end

    it "should return :returned for 6" do
      subject.status_for(6).should == :returned
    end

    it "should return :cancelled for 7" do
      subject.status_for(7).should == :cancelled
    end
  end
end
