# encoding: utf-8
require 'spec_helper'

describe PagSeguro::Payment do
  before do
    if EMAIL == "seu_email_cadastrado@nopagseguro.com.br"
      pending "You need to set your email for your PagSeguro account in spec/pag_seguro/integration/config.yml in order to run this spec"
    elsif TOKEN == "SEU_TOKEN_GERADO_NO_PAG_SEGURO"
      pending "You need to set your token for your PagSeguro account in spec/pag_seguro/integration/config.yml in order to run this spec"
    end
  end

  context "with all fields" do
    let(:payment){ build :payment_with_all_fields, email: EMAIL, token: TOKEN }
    subject { payment }

    its('code.size'){ should == 32 }
    its(:date){ should be_an_instance_of(DateTime) }

    it "should give a response code of 200 for the user pagseguro url" do
      RestClient.get(payment.checkout_payment_url).code.should == 200
    end
  end

  context "with item and minimum pre approval" do
    let(:payment){ build :payment_with_item, email: EMAIL, token: TOKEN, pre_approval: build(:minimum_pre_approval) }
    subject { payment }

    its('code.size'){ should == 32 }
    its(:date){ should be_an_instance_of(DateTime) }

    it "should give a response code of 200 for the user pagseguro url" do
      RestClient.get(payment.checkout_payment_url).code.should == 200
    end
  end

  context "with items" do
    let(:payment){ build :payment_with_items, email: EMAIL, token: TOKEN }
    subject { payment }

    its('code.size'){ should == 32 }
    its(:date){ should be_an_instance_of(DateTime) }

    it "should give a response code of 200 for the user pagseguro url" do
      RestClient.get(payment.checkout_payment_url).code.should == 200
    end
  end

  context "without items" do
    it "should raise error when fetching its code" do
      payment = build :payment, email: EMAIL, token: TOKEN
      expect { payment.code }.to raise_error(PagSeguro::Errors::InvalidData)
    end
  end

  it "should raise unauthorized error if email and token do not match" do
    payment = build :payment, email: "not_a_user@not_an_email.com", token: "NOTATOKEN7F048A09A8AEFDD1E5A7B91"
    expect { payment.code }.to raise_error(PagSeguro::Errors::Unauthorized)
  end
end
