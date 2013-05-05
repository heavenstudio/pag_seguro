# encoding: utf-8
require 'spec_helper'

describe PagSeguro::Payment do
  let(:payment){ PagSeguro::Payment.new }
  let(:xml){ Nokogiri::XML(payment.checkout_xml) }

  # Nokogiri helper methods
  def xml_content(selector)
    xml.css(selector).present? ? xml.css(selector).first.content : []
  end

  def xml_collection(selector)
    xml.css(selector).map(&:content)
  end

  context 'checkout_xml' do
    it 'should be a valid xml' do
      expect { Nokogiri::XML(payment.checkout_xml) { |config| config.options = Nokogiri::XML::ParseOptions::STRICT } }.to_not raise_error
    end

    its(:checkout_xml){ should match(/^<\?xml.+encoding="UTF-8".+\?>$/) }

    describe 'settings' do
      it { xml_content('checkout reference').should be_empty }
      it { xml_content('checkout extraAmount').should be_empty }
      it { xml_content('checkout redirectURL').should be_empty }
      it { xml_content('checkout maxUses').should be_empty }
      it { xml_content('checkout maxAge').should be_empty }
      it { xml_content('checkout currency').should == 'BRL' }

      context 'with id' do
        before{ payment.id = 305 }
        it { xml_content('checkout reference').should == '305' }
      end

      context 'with extra amount' do
        before{ payment.extra_amount = '10.50' }
        it { xml_content('checkout extraAmount').should == '10.50' }
      end

      context 'with redirect url' do
        before{ payment.redirect_url = 'http://heavenstudio.com.br' }
        it { xml_content('checkout redirectURL').should == 'http://heavenstudio.com.br' }
      end

      context 'with max uses' do
        before{ payment.max_uses = '10' }
        it { xml_content('checkout maxUses').should == '10' }
      end

      context 'with max age' do
        before{ payment.max_age = '5000' }
        it { xml_content('checkout maxAge').should == '5000' }
      end
    end

    describe 'items' do
      let(:payment){ build :payment_with_items }

      it { xml_collection('checkout items item').size.should == 4 }
      it { xml_collection('checkout items item id').should == ['25', '73', '95', '17'] }
      it { xml_collection('checkout items item description').should == ['A Bic Pen', 'A Book & Cover', 'A Towel', 'A pipe'] }
      it { xml_collection('checkout items item amount').should == ['1.50', '38.23', '69.35', '3.00'] }
      it { xml_collection('checkout items item quantity').should == ['4', '1', '2', '89'] }
      it { xml_collection('checkout items item shippingCost').should == ['1.00', '12.00'] }
      it { xml_collection('checkout items item weight').should == ['10', '300', '400'] }

      it 'should escape html in item description' do
        payment.checkout_xml.should include('A Book &amp; Cover')
      end
    end

    describe 'sender info' do
      context 'without sender' do
        it { xml_content('checkout sender name').should be_empty }
        it { xml_content('checkout sender email').should be_empty }
        it { xml_content('checkout sender phone areaCode').should be_empty }
        it { xml_content('checkout sender phone number').should be_empty }
      end

      context 'with sender' do
        let(:payment){ build :payment_with_sender }

        it { xml_content('checkout sender name').should == 'Stefano Diem Benatti' }
        it { xml_content('checkout sender email').should == 'stefano@heavenstudio.com.br' }
        it { xml_content('checkout sender phone areaCode').should == '11' }
        it { xml_content('checkout sender phone number').should == '993430994' }
      end
    end

    describe 'shipping info' do
      context 'without shipping' do
        it { xml_content('checkout shipping').should be_empty }
        it { xml_content('checkout shipping address').should be_empty }
      end

      context 'with empty shipping' do
        before{ payment.shipping = PagSeguro::Shipping.new }

        it { xml_content('checkout shipping').should_not be_empty }
        it { xml_content('checkout shipping address').should_not be_empty }
        it { xml_content('checkout shipping address state').should be_empty }
        it { xml_content('checkout shipping address city').should be_empty }
        it { xml_content('checkout shipping address postalCode').should be_empty }
        it { xml_content('checkout shipping address district').should be_empty }
        it { xml_content('checkout shipping address street').should be_empty }
        it { xml_content('checkout shipping address number').should be_empty }
        it { xml_content('checkout shipping address complement').should be_empty }
        it { xml_content('checkout shipping type').to_i.should == PagSeguro::Shipping::UNIDENTIFIED }
      end

      context 'with shipping' do
        let(:payment){ build :payment_with_shipping }

        it { xml_content('checkout shipping').should_not be_empty }
        it { xml_content('checkout shipping address').should_not be_empty }
        it { xml_content('checkout shipping type').to_i.should == PagSeguro::Shipping::SEDEX }
        it { xml_content('checkout shipping cost').should == '12.13' }
        it { xml_content('checkout shipping address state').should == 'SP' }
        it { xml_content('checkout shipping address city').should == 'São Paulo' }
        it { xml_content('checkout shipping address postalCode').should == '05363000' }
        it { xml_content('checkout shipping address district').should == 'Jd. PoliPoli' }
        it { xml_content('checkout shipping address street').should == 'Av. Otacilio Tomanik' }
        it { xml_content('checkout shipping address number').should == '775' }
        it { xml_content('checkout shipping address complement').should == 'apto. 92' }
      end
    end

    describe 'pre approval info' do
      context 'without pre approval' do
        it { xml_content('checkout preApproval').should be_empty }
      end

      context 'with pre_approval' do
        let(:payment){ build :payment_with_pre_approval }

        it { xml_content('checkout preApproval').should_not be_empty }
        it { xml_content('checkout preApproval name').should == 'Super seguro para notebook' }
        it { xml_content('checkout preApproval details').should == 'Toda segunda feira será cobrado o valor de R$150,00 para o seguro do notebook' }
        it { xml_content('checkout preApproval amountPerPayment').should == '150.00' }
        it { xml_content('checkout preApproval initialDate').should == '2015-01-17T00:00:00+00:00' }
        it { xml_content('checkout preApproval finalDate').should == '2017-01-17T00:00:00+00:00' }
        it { xml_content('checkout preApproval maxAmountPerPeriod').should == '200.00' }
        it { xml_content('checkout preApproval maxTotalAmount').should == '900.00' }
        it { xml_content('checkout preApproval reviewURL').should == 'http://sounoob.com.br/produto1' }

        context 'weekly' do
          let(:payment){ build :payment_with_weekly_pre_approval }

          it { xml_content('checkout preApproval period').should == 'weekly' }
          it { xml_content('checkout preApproval dayOfWeek').should == 'monday' }
          it { xml_content('checkout preApproval dayOfMonth').should be_empty }
          it { xml_content('checkout preApproval dayOfYear').should be_empty }
        end

        context 'monthly' do
          let(:payment){ build :payment_with_monthly_pre_approval }

          it { xml_content('checkout preApproval period').should == 'monthly' }
          it { xml_content('checkout preApproval dayOfWeek').should be_empty }
          it { xml_content('checkout preApproval dayOfMonth').should == '3' }
          it { xml_content('checkout preApproval dayOfYear').should be_empty }
        end

        context 'yearly' do
          let(:payment){ build :payment_with_yearly_pre_approval }

          it { xml_content('checkout preApproval period').should == 'yearly' }
          it { xml_content('checkout preApproval dayOfWeek').should be_empty }
          it { xml_content('checkout preApproval dayOfMonth').should be_empty }
          it { xml_content('checkout preApproval dayOfYear').should == '03-01' }
        end
      end
    end
  end
end
