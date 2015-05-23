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
      it { expect(xml_content('checkout reference')).to be_empty }
      it { expect(xml_content('checkout extraAmount')).to be_empty }
      it { expect(xml_content('checkout redirectURL')).to be_empty }
      it { expect(xml_content('checkout maxUses')).to be_empty }
      it { expect(xml_content('checkout maxAge')).to be_empty }
      it { expect(xml_content('checkout currency')).to eq('BRL') }

      context 'with id' do
        before{ payment.id = 305 }
        it { expect(xml_content('checkout reference')).to eq('305') }
      end

      context 'with extra amount' do
        before{ payment.extra_amount = '10.50' }
        it { expect(xml_content('checkout extraAmount')).to eq('10.50') }
      end

      context 'with redirect url' do
        before{ payment.redirect_url = 'http://heavenstudio.com.br' }
        it { expect(xml_content('checkout redirectURL')).to eq('http://heavenstudio.com.br') }
      end

      context 'with notification url' do
        before{ payment.notification_url = 'http://heavenstudio.com.br/notification' }
        it { expect(xml_content('checkout notificationURL')).to eq('http://heavenstudio.com.br/notification') }
      end

      context 'with max uses' do
        before{ payment.max_uses = '10' }
        it { expect(xml_content('checkout maxUses')).to eq('10') }
      end

      context 'with max age' do
        before{ payment.max_age = '5000' }
        it { expect(xml_content('checkout maxAge')).to eq('5000') }
      end
    end

    describe 'items' do
      let(:payment){ build :payment_with_items }

      it { expect(xml_collection('checkout items item').size).to eq(4) }
      it { expect(xml_collection('checkout items item id')).to eq(['25', '73', '95', '17']) }
      it { expect(xml_collection('checkout items item description')).to eq(['A Bic Pen', 'A Book & Cover', 'A Towel', 'A pipe']) }
      it { expect(xml_collection('checkout items item amount')).to eq(['1.50', '38.23', '69.35', '3.00']) }
      it { expect(xml_collection('checkout items item quantity')).to eq(['4', '1', '2', '89']) }
      it { expect(xml_collection('checkout items item shippingCost')).to eq(['1.00', '12.00']) }
      it { expect(xml_collection('checkout items item weight')).to eq(['10', '300', '400']) }

      it 'should escape html in item description' do
        expect(payment.checkout_xml).to include('A Book &amp; Cover')
      end
    end

    describe 'sender info' do
      context 'without sender' do
        it { expect(xml_content('checkout sender name')).to be_empty }
        it { expect(xml_content('checkout sender email')).to be_empty }
        it { expect(xml_content('checkout sender phone areaCode')).to be_empty }
        it { expect(xml_content('checkout sender phone number')).to be_empty }
      end

      context 'with sender' do
        let(:payment){ build :payment_with_sender }

        it { expect(xml_content('checkout sender name')).to eq('Stefano Diem Benatti') }
        it { expect(xml_content('checkout sender email')).to eq('stefano@heavenstudio.com.br') }
        it { expect(xml_content('checkout sender phone areaCode')).to eq('11') }
        it { expect(xml_content('checkout sender phone number')).to eq('993430994') }
      end
    end

    describe 'shipping info' do
      context 'without shipping' do
        it { expect(xml_content('checkout shipping')).to be_empty }
        it { expect(xml_content('checkout shipping address')).to be_empty }
      end

      context 'with empty shipping' do
        before{ payment.shipping = PagSeguro::Shipping.new }

        it { expect(xml_content('checkout shipping')).not_to be_empty }
        it { expect(xml_content('checkout shipping address')).not_to be_empty }
        it { expect(xml_content('checkout shipping address state')).to be_empty }
        it { expect(xml_content('checkout shipping address city')).to be_empty }
        it { expect(xml_content('checkout shipping address postalCode')).to be_empty }
        it { expect(xml_content('checkout shipping address district')).to be_empty }
        it { expect(xml_content('checkout shipping address street')).to be_empty }
        it { expect(xml_content('checkout shipping address number')).to be_empty }
        it { expect(xml_content('checkout shipping address complement')).to be_empty }
        it { expect(xml_content('checkout shipping type').to_i).to eq(PagSeguro::Shipping::UNIDENTIFIED) }
      end

      context 'with shipping' do
        let(:payment){ build :payment_with_shipping }

        it { expect(xml_content('checkout shipping')).not_to be_empty }
        it { expect(xml_content('checkout shipping address')).not_to be_empty }
        it { expect(xml_content('checkout shipping type').to_i).to eq(PagSeguro::Shipping::SEDEX) }
        it { expect(xml_content('checkout shipping cost')).to eq('12.13') }
        it { expect(xml_content('checkout shipping address state')).to eq('SP') }
        it { expect(xml_content('checkout shipping address city')).to eq('São Paulo') }
        it { expect(xml_content('checkout shipping address postalCode')).to eq('05363000') }
        it { expect(xml_content('checkout shipping address district')).to eq('Jd. PoliPoli') }
        it { expect(xml_content('checkout shipping address street')).to eq('Av. Otacilio Tomanik') }
        it { expect(xml_content('checkout shipping address number')).to eq('775') }
        it { expect(xml_content('checkout shipping address complement')).to eq('apto. 92') }
      end
    end

    describe 'pre approval info' do
      context 'without pre approval' do
        it { expect(xml_content('checkout preApproval')).to be_empty }
      end

      context 'with pre_approval' do
        let(:payment){ build :payment_with_pre_approval }

        it { expect(xml_content('checkout preApproval')).not_to be_empty }
        it { expect(xml_content('checkout preApproval name')).to eq('Super seguro para notebook') }
        it { expect(xml_content('checkout preApproval details')).to eq('Toda segunda feira será cobrado o valor de R$150,00 para o seguro do notebook') }
        it { expect(xml_content('checkout preApproval amountPerPayment')).to eq('150.00') }
        it { expect(xml_content('checkout preApproval initialDate')).to eq('2015-05-25T00:00:00+00:00') }
        it { expect(xml_content('checkout preApproval finalDate')).to eq('2017-05-22T00:00:00+00:00') }
        it { expect(xml_content('checkout preApproval maxAmountPerPeriod')).to eq('200.00') }
        it { expect(xml_content('checkout preApproval maxTotalAmount')).to eq('900.00') }
        it { expect(xml_content('checkout preApproval reviewURL')).to eq('http://sounoob.com.br/produto1') }

        context 'weekly' do
          let(:payment){ build :payment_with_weekly_pre_approval }

          it { expect(xml_content('checkout preApproval period')).to eq('weekly') }
          it { expect(xml_content('checkout preApproval dayOfWeek')).to eq('monday') }
          it { expect(xml_content('checkout preApproval dayOfMonth')).to be_empty }
          it { expect(xml_content('checkout preApproval dayOfYear')).to be_empty }
        end

        context 'monthly' do
          let(:payment){ build :payment_with_monthly_pre_approval }

          it { expect(xml_content('checkout preApproval period')).to eq('monthly') }
          it { expect(xml_content('checkout preApproval dayOfWeek')).to be_empty }
          it { expect(xml_content('checkout preApproval dayOfMonth')).to eq('3') }
          it { expect(xml_content('checkout preApproval dayOfYear')).to be_empty }
        end

        context 'yearly' do
          let(:payment){ build :payment_with_yearly_pre_approval }

          it { expect(xml_content('checkout preApproval period')).to eq('yearly') }
          it { expect(xml_content('checkout preApproval dayOfWeek')).to be_empty }
          it { expect(xml_content('checkout preApproval dayOfMonth')).to be_empty }
          it { expect(xml_content('checkout preApproval dayOfYear')).to eq('03-01') }
        end
      end
    end
  end
end
