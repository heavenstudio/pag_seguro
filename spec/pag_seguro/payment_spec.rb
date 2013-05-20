require 'spec_helper'

describe PagSeguro::Payment do
  let(:payment){ PagSeguro::Payment.new }
  subject{ payment }

  it { should have_attribute_accessor(:id) }
  it { should have_attribute_accessor(:items) }
  it { should have_attribute_accessor(:sender) }
  it { should have_attribute_accessor(:shipping) }
  it { should have_attribute_accessor(:email) }
  it { should have_attribute_accessor(:token) }
  it { should have_attribute_accessor(:extra_amount) }
  it { should have_attribute_accessor(:redirect_url) }
  it { should have_attribute_accessor(:max_uses) }
  it { should have_attribute_accessor(:max_age) }
  it { should have_attribute_accessor(:response) }
  it { should have_attribute_accessor(:pre_approval) }

  it { should respond_to :code }
  it { should respond_to :date }

  describe "::CHECKOUT_URL" do
    subject { PagSeguro::Payment::CHECKOUT_URL }
    it { should == "https://ws.pagseguro.uol.com.br/v2/checkout" }
  end

  describe '#date' do
    subject{ payment.send(:parse_date) }
    before{ payment.stub response: double(:response, body: '<checkout><date>2001-02-03T04:05:06+07:00</date></checkout>') }

    it { should be_an_instance_of(DateTime) }
    its(:year){ should == 2001 }
    its(:month){ should == 2 }
    its(:day){ should == 3 }
  end

  describe '#code' do
    before{ payment.stub response: double(:response, body: '<checkout><code>EE603A-59F0DEF0DAAD-2334FFBF9A1E-3223E3</code></checkout>') }

    its(:code){ should == 'EE603A-59F0DEF0DAAD-2334FFBF9A1E-3223E3' }
  end

  its(:items){ should be_an_instance_of(Array) }
  its(:items){ should be_empty }
  its(:sender){ should be_an_instance_of(PagSeguro::Sender) }

  context 'with email and token initialization' do
    subject{ build(:payment) }
    let(:payment){ subject }
    its(:email){ should == 'myemail' }
    its(:token){ should == 'mytoken' }

    it { validate_presence_of :email }
    it { validate_presence_of :token }

    it { should_not allow_value('10,50').for(:extra_amount) }
    it { should_not allow_value('R$ 10.50').for(:extra_amount) }
    it { should_not allow_value('-10.50').for(:extra_amount) }
    it { should_not allow_value('10.50\nanything').for(:extra_amount) }
    it { should allow_value('10.50').for(:extra_amount) }
    it { should allow_value(10).for(:extra_amount) }
    it { should allow_value(BigDecimal.new('10.5')).for(:extra_amount) }

    it { should_not allow_value('something.com.br').for(:redirect_url)}
    it { should allow_value('http://something.com.br').for(:redirect_url)}

    it { should_not allow_value(0).for(:max_uses) }
    it { should_not allow_value('0').for(:max_uses) }
    it { should allow_value(10).for(:max_uses) }
    it { should allow_value('10').for(:max_uses) }

    it { should_not allow_value(29).for(:max_age) }
    it { should allow_value(30).for(:max_age) }

    it 'should not be valid if its pre_approval in invalid' do
      payment.pre_approval = PagSeguro::PreApproval.new
      payment.should_not be_valid
    end

    it 'should not be valid if one of its items is invalid' do
      payment.items = [PagSeguro::Item.new]
      payment.should_not be_valid
    end

    context 'without items' do
      it { should_not be_valid }
    end

    context 'with items' do
      subject { build :payment_with_item }
      it { should be_valid }
    end

    context 'using reference instead of id' do
      subject { build :payment_with_item, id: nil, reference: "REF1234" }
      its(:id){ should == "REF1234" }
      its(:reference){ should == "REF1234" }
    end

    context 'checking out' do
      let(:payment){ build(:payment) }
      it 'should generate a checkout url with an external code' do
        PagSeguro::Payment.checkout_payment_url('aabbcc').should == 'https://pagseguro.uol.com.br/v2/checkout/payment.html?code=aabbcc'
      end

      it 'should generate a checkout url based on the received response' do
        payment.stub code: 'aabbcc'
        payment.checkout_payment_url.should == 'https://pagseguro.uol.com.br/v2/checkout/payment.html?code=aabbcc'
      end
    end

    describe '#parse_checkout_response' do

      it 'should not raise errors if response code is 200' do
        PagSeguro::Payment.any_instance.stub_chain(:send_checkout, :code){ 200 }
        PagSeguro::Payment.any_instance.stub_chain(:send_checkout, :body){ 'some body info' }
        expect { payment.send(:parse_checkout_response) }.to_not raise_error
      end

      it 'should raise PagSeguro::Errors::InvalidData if response code is 400' do
        PagSeguro::Payment.any_instance.stub_chain(:send_checkout, :code){ 400 }
        PagSeguro::Payment.any_instance.stub_chain(:send_checkout, :body){ 'some error description' }
        expect { payment.send(:parse_checkout_response) }.to raise_error(PagSeguro::Errors::InvalidData)
      end

      it 'should raise PagSeguro::Errors::Unauthorized if response code is 400' do
        PagSeguro::Payment.any_instance.stub_chain(:send_checkout, :code){ 401 }
        expect { payment.send(:parse_checkout_response) }.to raise_error(PagSeguro::Errors::Unauthorized)
      end

      it 'should raise PagSeguro::Errors::UnknownError if response code is not 200, 400 or 401' do
        PagSeguro::Payment.any_instance.stub_chain(:send_checkout, :code){ 300 }
        PagSeguro::Payment.any_instance.stub_chain(:send_checkout, :body){ 'some response body' }
        expect { payment.send(:parse_checkout_response) }.to raise_error(PagSeguro::Errors::UnknownError)
      end

      it 'should set response attribute if code is 200' do
        PagSeguro::Payment.any_instance.stub_chain(:send_checkout, :code){ 200 }
        PagSeguro::Payment.any_instance.stub_chain(:send_checkout, :body){ 'some response body' }
        expect { payment.send(:parse_checkout_response) }.to change { payment.response }.from(nil).to('some response body')
      end

      it 'should be able to reset response' do
        payment.response = 'something'
        expect { payment.reset! }.to change{ payment.response }.from('something').to(nil)
      end
    end
  end

  describe '#code' do
    it 'should call #parse_checkout_response if #response is nil' do
      payment.stub(response: nil, parse_code: nil)
      payment.should_receive(:parse_checkout_response)
      payment.code
    end

    it 'should not call #parse_checkout_response if #response is present' do
      payment.stub(response: true, parse_code: nil)
      payment.should_not_receive(:parse_checkout_response)
      payment.code
    end

    it 'should call #parse_code' do
      payment.stub(response: true)
      payment.should_receive(:parse_code)
      payment.code
    end
  end

  describe '#date' do
    it 'should call #parse_checkout_response if #response is nil' do
      payment.stub(response: nil, parse_date: nil)
      payment.should_receive(:parse_checkout_response)
      payment.date
    end

    it 'should not call #parse_checkout_response if #response is present' do
      payment.stub(response: true, parse_date: nil)
      payment.should_not_receive(:parse_checkout_response)
      payment.date
    end

    it 'should call #parse_code' do
      payment.stub(response: true)
      payment.should_receive(:parse_date)
      payment.date
    end
  end

  describe "#send_checkout" do
    let(:payment){ PagSeguro::Payment.new "email@mail.com", "sometoken" }
    it "should call pagseguro's webservice" do
      checkout_xml = double(:checkout_xml)
      payment.stub(checkout_xml: checkout_xml)
      params = { email: "email@mail.com", token: "sometoken" }
      RestClient.should_receive(:post).with(
        PagSeguro::Payment::CHECKOUT_URL,
        checkout_xml,
        params: params,
        content_type: "application/xml")
      payment.send :send_checkout
    end
  end
end
