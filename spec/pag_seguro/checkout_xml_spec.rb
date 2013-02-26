# encoding: utf-8
require 'spec_helper'

items = [
  PagSeguro::Item.new(id: 25, description: "A Bic Pen", amount: "1.50",  quantity: "4", shipping_cost: "1.00",  weight: 10),
  PagSeguro::Item.new(id: 73, description: "A Book & Cover",    amount: "38.23", quantity: "1", shipping_cost: "12.00", weight: 300),
  PagSeguro::Item.new(id: 95, description: "A Towel",   amount: "69.35", quantity: "2", weight: 400),
  PagSeguro::Item.new(id: 17, description: "A pipe",    amount: "3.00",  quantity: "89")
]

sender_info = {name: "Stefano Diem Benatti", email: "stefano@heavenstudio.com.br", phone_ddd: "11", phone_number: "93430994"}

shipping_info = {type: PagSeguro::Shipping::SEDEX, state: "SP", city: "São Paulo", postal_code: "05363000",
  district: "Jd. PoliPoli", street: "Av. Otacilio Tomanik", number: "775", complement: "apto. 92", cost: "12.13" }


describe PagSeguro::Payment do
  context "checkout_xml" do
    before { @payment = PagSeguro::Payment.new }
    
    it "should be a valid xml" do
      lambda { Nokogiri::XML(@payment.checkout_xml) { |config| config.options = Nokogiri::XML::ParseOptions::STRICT } }.should_not raise_error
    end
    
    it "should have encoding UTF-8" do
      @payment.checkout_xml.should match(/^<\?xml.+encoding="UTF-8".+\?>$/)
    end
    
    it "should have currency BRL" do
      Nokogiri::XML(@payment.checkout_xml).css("checkout currency").first.content.should == "BRL"
    end
    
    context "items" do
      before do
        @payment.items = items
        @xml = Nokogiri::XML(@payment.checkout_xml)
      end

      it "should have 4 items" do
        @xml.css("checkout items item").size.should == 4
      end
      
      it "should show all ids" do
        @xml.css("checkout items item id").map(&:content).should == ["25","73","95","17"]
      end
      
      it "should show all descriptions escaping html" do
        @xml.css("checkout items item description").map(&:content).should == ["A Bic Pen","A Book & Cover","A Towel","A pipe"]
      end
      
      it "should escape html in item description" do
        @payment.checkout_xml.should include("A Book &amp; Cover")
      end
      
      it "should show all amounts" do
        @xml.css("checkout items item amount").map(&:content).should == ["1.50","38.23","69.35","3.00"]
      end

      it "should show all quantities" do
        @xml.css("checkout items item quantity").map(&:content).should == ["4","1","2","89"]
      end
      
      it "should show all shipping_costs" do
        @xml.css("checkout items item shippingCost").map(&:content).should == ["1.00","12.00"]
      end

      it "should show all weights" do
        @xml.css("checkout items item weight").map(&:content).should == ["10","300","400"]
      end
    end
    
    context "sender info" do
      before do
        @xml_without_sender_info = Nokogiri::XML(@payment.checkout_xml)
        @payment.sender = PagSeguro::Sender.new(sender_info)
        @xml = Nokogiri::XML(@payment.checkout_xml)
      end
      
      it "should have sender name" do
        @xml_without_sender_info.css("checkout sender name").should be_empty
        @xml.css("checkout sender name").first.content.should == "Stefano Diem Benatti"
      end

      it "should have sender email" do
        @xml_without_sender_info.css("checkout sender email").should be_empty
        @xml.css("checkout sender email").first.content.should == "stefano@heavenstudio.com.br"
      end

      it "should have sender phone ddd" do
        @xml_without_sender_info.css("checkout sender phone areaCode").should be_empty
        @xml.css("checkout sender phone areaCode").first.content.should == "11"
      end

      it "should have sender phone number" do
        @xml_without_sender_info.css("checkout sender phone number").should be_empty
        @xml.css("checkout sender phone number").first.content.should == "93430994"
      end
    end
    
    context "shipping" do
      before do
        @xml_without_shipping_info = Nokogiri::XML(@payment.checkout_xml)
        @payment.shipping = PagSeguro::Shipping.new(shipping_info)
        @xml = Nokogiri::XML(@payment.checkout_xml)
      end
      
      it "should not have any shipping info unless shipping is provided" do
        @xml_without_shipping_info.css("checkout shipping").should be_empty
        @xml.css("checkout shipping").should_not be_empty
      end
      
      it "should have a default shipping type of UNINDENTIFIED" do
        @payment.shipping = PagSeguro::Shipping.new
        xml_with_empty_shipping = Nokogiri::XML(@payment.checkout_xml)
        xml_with_empty_shipping.css("checkout shipping type").first.content.to_i.should == PagSeguro::Shipping::UNIDENTIFIED
      end
      
      it "should allow to set a different shipping type" do
        @xml.css("checkout shipping type").first.content.to_i.should == PagSeguro::Shipping::SEDEX
      end

      it "should allow to set a shipping cost" do
        @xml.css("checkout shipping cost").first.content.should == "12.13"
      end

      it "should have state" do
        @xml_without_shipping_info.css("checkout shipping address state").should be_empty
        @xml.css("checkout shipping address state").first.content.should == "SP"
      end

      it "should have city" do
        @xml_without_shipping_info.css("checkout shipping address city").should be_empty
        @xml.css("checkout shipping address city").first.content.should == "São Paulo"
      end

      it "should have postal code" do
        @xml_without_shipping_info.css("checkout shipping address postalCode").should be_empty
        @xml.css("checkout shipping address postalCode").first.content.should == "05363000"
      end

      it "should have district" do
        @xml_without_shipping_info.css("checkout shipping address district").should be_empty
        @xml.css("checkout shipping address district").first.content.should == "Jd. PoliPoli"
      end

      it "should have street" do
        @xml_without_shipping_info.css("checkout shipping address street").should be_empty
        @xml.css("checkout shipping address street").first.content.should == "Av. Otacilio Tomanik"
      end

      it "should have number" do
        @xml_without_shipping_info.css("checkout shipping address number").should be_empty
        @xml.css("checkout shipping address number").first.content.should == "775"
      end

      it "should have complement" do
        @xml_without_shipping_info.css("checkout shipping address complement").should be_empty
        @xml.css("checkout shipping address complement").first.content.should == "apto. 92"
      end
    end
    
    context "payment settings" do
      it "should not show id unless specified" do
        Nokogiri::XML(@payment.checkout_xml).css("checkout reference").should be_empty
        @payment.id = 305
        Nokogiri::XML(@payment.checkout_xml).css("checkout reference").first.content.should == "305"
      end
      
      it "should not show extra amount unless specified" do
        Nokogiri::XML(@payment.checkout_xml).css("checkout extraAmount").should be_empty
        @payment.extra_amount = "10.50"
        Nokogiri::XML(@payment.checkout_xml).css("checkout extraAmount").first.content.should == "10.50"
      end
      
      it "should not show redirect url unless specified" do
        Nokogiri::XML(@payment.checkout_xml).css("checkout redirectURL").should be_empty
        @payment.redirect_url = "http://heavenstudio.com.br"
        Nokogiri::XML(@payment.checkout_xml).css("checkout redirectURL").first.content.should == "http://heavenstudio.com.br"
      end
      
      it "should not show max uses unless specified" do
        Nokogiri::XML(@payment.checkout_xml).css("checkout maxUses").should be_empty
        @payment.max_uses = "10"
        Nokogiri::XML(@payment.checkout_xml).css("checkout maxUses").first.content.should == "10"
      end
      
      it "should not show max age unless specified" do
        Nokogiri::XML(@payment.checkout_xml).css("checkout maxAge").should be_empty
        @payment.max_age = "5000"
        Nokogiri::XML(@payment.checkout_xml).css("checkout maxAge").first.content.should == "5000"
      end
    end
  end
end
