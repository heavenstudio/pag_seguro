# encoding: utf-8
require 'spec_helper'

describe PagSeguro::PaymentMethod do
  it { should have_attribute_accessor(:code) }
  it { should have_attribute_accessor(:type) }

  context "initalized with code and type" do
    subject { build :payment_method, code: "101", type: "1" }

    its(:code){ should == 101 }
    its(:type){ should == 1 }
  end

  describe "types" do
    let(:payment_method){ PagSeguro::PaymentMethod.new }

    context "with type 1" do
      subject { build :payment_method, type: 1 }
      it { should be_credit_card }
    end

    context "with if type 2" do
      subject { build :payment_method, type: 2 }
      it { should be_bank_bill }
    end

    context "with if type 3" do
      subject { build :payment_method, type: 3 }
      it { should be_online_debit }
    end

    context "with if type 4" do
      subject { build :payment_method, type: 4 }
      it { should be_pag_seguro_balance }
    end

    context "with type 5" do
      subject { build :payment_method, type: 5 }
      it { should be_oi_paggo }
    end
  end

  describe "codes" do
    def should_have_meaning_for_code(meaning, code)
      PagSeguro::PaymentMethod.new(code: code).name.should be == meaning
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
