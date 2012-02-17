# encoding: utf-8
require 'spec_helper'

describe PagSeguro::PaymentMethod do
  context "instance" do
    context "accessors" do
      before { @payment_method = PagSeguro::PaymentMethod.new }
      
      it { @payment_method.should have_attribute_accessor(:code) }
	    it { @payment_method.should have_attribute_accessor(:type) }      
	  end
    
    it "should be able to initialize with all attributes" do
      payment_method = PagSeguro::PaymentMethod.new(code: "101", type: "1")
      payment_method.code.should == 101
      payment_method.type.should == 1
    end
    
    describe "types" do
      before { @payment_method = PagSeguro::PaymentMethod.new }
      
      it "should be credit card if type is 1" do
        @payment_method.stub(:type){ 1 }
        @payment_method.should be_credit_card
      end
      
      it "should be bank bill if type is 2" do
        @payment_method.stub(:type){ 2 }
        @payment_method.should be_bank_bill
      end
      
      it "should be online debit if type is 3" do
        @payment_method.stub(:type){ 3 }
        @payment_method.should be_online_debit
      end

      it "should be PagSeguro balance if type is 4" do
        @payment_method.stub(:type){ 4 }
        @payment_method.should be_pag_seguro_balance
      end
      
      it "should be oi paggo if type is 5" do
        @payment_method.stub(:type){ 5 }
        @payment_method.should be_oi_paggo
      end
    end
    
    describe "codes" do
      def should_have_meaning_for_code(meaning, code)
        PagSeguro::PaymentMethod.new(code: code).name.should == meaning
      end
      
      it { should_have_meaning_for_code("Cartão de crédito Visa", 101) }
      it { should_have_meaning_for_code("Cartão de crédito MasterCard", 102) }
      it { should_have_meaning_for_code("Cartão de crédito American Express", 103) }
      it { should_have_meaning_for_code("Cartão de crédito Diners", 104) }
      it { should_have_meaning_for_code("Cartão de crédito Hipercard", 105) }
      it { should_have_meaning_for_code("Cartão de crédito Aura", 106) }
      it { should_have_meaning_for_code("Cartão de crédito Elo", 107) }
      it { should_have_meaning_for_code("Cartão de crédito PLENOCard", 108) }
      it { should_have_meaning_for_code("Cartão de crédito PersonalCard", 109) }
      it { should_have_meaning_for_code("Boleto Bradesco", 201) }
      it { should_have_meaning_for_code("Boleto Santander", 202) }
      it { should_have_meaning_for_code("Débito online Bradesco", 301) }
      it { should_have_meaning_for_code("Débito online Itaú", 302) }
      it { should_have_meaning_for_code("Débito online Unibanco", 303) }
      it { should_have_meaning_for_code("Débito online Banco do Brasil", 304) }
      it { should_have_meaning_for_code("Débito online Banco Real", 305) }
      it { should_have_meaning_for_code("Débito online Banrisul", 306) }
      it { should_have_meaning_for_code("Débito online HSBC", 307) }
      it { should_have_meaning_for_code("Saldo PagSeguro", 401) }
      it { should_have_meaning_for_code("Oi Paggo", 501) }
      it { should_have_meaning_for_code("Desconhecido", 0) }
    end
  end
end