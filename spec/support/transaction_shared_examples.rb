# encoding: UTF-8
shared_examples_for "a transaction" do
  let(:transaction_xml){ File.open( File.expand_path( File.dirname(__FILE__) + '/../fixtures/transaction.xml') ) }
  let(:transaction_data){ Nokogiri::XML(transaction_xml) }

  context "sandbox" do
    before do
      PagSeguro::Url.environment=:sandbox
    end

    it "transactions url" do
      expect(PagSeguro::Transaction.transactions_url).to eq "https://ws.sandbox.pagseguro.uol.com.br/v2/transactions"
    end
  end

  context "production" do
    before do
      PagSeguro::Url.environment=:production
    end
    describe "transactions url" do
      it {expect(PagSeguro::Transaction.transactions_url).to eq "https://ws.pagseguro.uol.com.br/v2/transactions"}
    end

    it "should have an id" do
      expect(transaction.id).to eq("REF1234")
    end

    it "should have a reference" do
      expect(transaction.reference).to eq("REF1234")
    end

    it "should have a transaction id" do
      expect(transaction.transaction_id).to eq("9E884542-81B3-4419-9A75-BCC6FB495EF1")
    end

    it "should have a gross amount" do
      expect(transaction.gross_amount).to be_present
      expect(transaction.gross_amount).to match(/^\d+\.\d{2}$/)
    end

    it "should have a discount amount" do
      expect(transaction.discount_amount).to be_present
      expect(transaction.discount_amount).to match(/^\d+\.\d{2}$/)
    end

    it "should have a fee amount" do
      expect(transaction.fee_amount).to be_present
      expect(transaction.fee_amount).to match(/^\d+\.\d{2}$/)
    end

    it "should have a net amount" do
      expect(transaction.net_amount).to be_present
      expect(transaction.net_amount).to match(/^\d+\.\d{2}$/)
    end

    it "should have an extra amount" do
      expect(transaction.extra_amount).to be_present
      expect(transaction.extra_amount).to match(/^\d+\.\d{2}$/)
    end

    it "should have an installment count" do
      expect(transaction.installment_count).to be_present
      expect(transaction.installment_count).to be_an_integer
    end

    it "should have an item count" do
      expect(transaction.item_count).to be_present
      expect(transaction.item_count).to be_an_integer
      expect(transaction.item_count).to eq(transaction.items.count)
    end

    it "should be approved in this case" do
      expect(transaction).to be_approved
    end

    it "should have a sender" do
      @sender = transaction.sender
      expect(@sender.name).to eq("Jose Comprador")
      expect(@sender.email).to eq("comprador@uol.com.br")
      expect(@sender.phone_ddd).to eq("11")
      @sender.phone_number == "56273440"
    end

    it "should have a date" do
      expect(transaction.date).to be_present
      expect(transaction.date).to be_an_instance_of(DateTime)
      expect(transaction.date.year).to eq(2011)
      expect(transaction.date.month).to eq(2)
      expect(transaction.date.day).to eq(10)
    end

    it "should have a last event date" do
      expect(transaction.last_event_date).to be_present
      expect(transaction.last_event_date).to be_an_instance_of(DateTime)
      expect(transaction.last_event_date.year).to eq(2011)
      expect(transaction.last_event_date.month).to eq(2)
      expect(transaction.last_event_date.day).to eq(10)
    end

    it "should have a escrow end date" do
      expect(transaction.escrow_end_date).to be_present
      expect(transaction.escrow_end_date).to be_an_instance_of(DateTime)
      expect(transaction.escrow_end_date.year).to eq(2011)
      expect(transaction.escrow_end_date.month).to eq(2)
      expect(transaction.escrow_end_date.day).to eq(10)
    end

    it "should have a shipping" do
      @shipping = transaction.shipping
      expect(@shipping.type).to eq(1)
      expect(@shipping.cost).to eq("21.50")
      expect(@shipping.state).to eq("SP")
      expect(@shipping.city).to eq("Sao Paulo")
      expect(@shipping.postal_code).to eq("01452002")
      expect(@shipping.district).to eq("Jardim Paulistano")
      expect(@shipping.street).to eq("Av. Brig. Faria Lima")
      expect(@shipping.number).to eq("1384")
      expect(@shipping.complement).to eq("5o andar")
    end

    it "should have a payment method" do
      @payment_method = transaction.payment_method
      expect(@payment_method.code).to eq(101)
      expect(@payment_method.type).to eq(1)
    end

    it "should have items" do
      @items = transaction.items
      expect(@items.size).to eq(2)

      expect(@items[0].id).to eq("0001")
      expect(@items[0].description).to eq("Notebook Prata")
      expect(@items[0].quantity).to eq("1")
      expect(@items[0].amount).to eq("24300.00")

      expect(@items[1].id).to eq("0002")
      expect(@items[1].description).to eq("Notebook Rosa")
      expect(@items[1].quantity).to eq("1")
      expect(@items[1].amount).to eq("25600.00")
    end

    describe "status" do
      it "should have a status" do
        expect(transaction.status).to eq(3)
      end

      it "should be processing if its status is 1" do
        allow(transaction).to receive(:status){ 1 }
        expect(transaction).to be_processing
      end

      it "should be in analysis if its status is 2" do
        allow(transaction).to receive(:status){ 2 }
        expect(transaction).to be_in_analysis
      end

      it "should be approved if its status is 3" do
        allow(transaction).to receive(:status){ 3 }
        expect(transaction).to be_approved
      end

      it "should be available if its status is 4" do
        allow(transaction).to receive(:status){ 4 }
        expect(transaction).to be_available
      end

      it "should be disputed if its status is 5" do
        allow(transaction).to receive(:status){ 5 }
        expect(transaction).to be_disputed
      end

      it "should be disputed if its status is 5" do
        allow(transaction).to receive(:status){ 5 }
        expect(transaction).to be_disputed
      end

      it "should be returned if its status is 6" do
        allow(transaction).to receive(:status){ 6 }
        expect(transaction).to be_returned
      end

      it "should be cancelled if its status is 7" do
        allow(transaction).to receive(:status){ 7 }
        expect(transaction).to be_cancelled
      end
    end

    describe "type" do
      it "should have a type" do
        expect(transaction.type).to eq(1)
      end

      it "should be payment if type is 1" do
        allow(transaction).to receive(:type){ 1 }
        expect(transaction).to be_payment
      end

      it "should be transfer if type is 2" do
        allow(transaction).to receive(:type){ 2 }
        expect(transaction).to be_transfer
      end

      it "should be addition of funds if type is 3" do
        allow(transaction).to receive(:type){ 3 }
        expect(transaction).to be_addition_of_funds
      end

      it "should be charge if type is 4" do
        allow(transaction).to receive(:type){ 4 }
        expect(transaction).to be_charge
      end

      it "should be bonus if type is 5" do
        allow(transaction).to receive(:type){ 5 }
        expect(transaction).to be_bonus
      end
    end

    describe "::status_for" do
      it "should return :processing for 1" do
        expect(subject.status_for(1)).to eq(:processing)
      end

      it "should return :in_analysis for 2" do
        expect(subject.status_for(2)).to eq(:in_analysis)
      end

      it "should return :approved for 3" do
        expect(subject.status_for(3)).to eq(:approved)
      end

      it "should return :available for 4" do
        expect(subject.status_for(4)).to eq(:available)
      end

      it "should return :disputed for 5" do
        expect(subject.status_for(5)).to eq(:disputed)
      end

      it "should return :returned for 6" do
        expect(subject.status_for(6)).to eq(:returned)
      end

      it "should return :cancelled for 7" do
        expect(subject.status_for(7)).to eq(:cancelled)
      end
    end
  end
end
