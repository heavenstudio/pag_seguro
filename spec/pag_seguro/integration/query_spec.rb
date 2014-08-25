# encoding: utf-8
require 'spec_helper'

describe PagSeguro::Query do
  describe "#new" do
    before :all do
      if EMAIL == "seu_email_cadastrado@nopagseguro.com.br"
        pending "You need to set your email for your PagSeguro account in spec/pag_seguro/integration/config.yml in order to run this spec"
      elsif TOKEN == "SEU_TOKEN_GERADO_NO_PAG_SEGURO"
        pending "You need to set your token for your PagSeguro account in spec/pag_seguro/integration/config.yml in order to run this spec"
      elsif TRANSACTION_ID == "UM_CODIGO_DE_TRANSACAO"
        pending "You need to set one transaction id for your PagSeguro account in spec/pag_seguro/integration/config.yml in order to run this spec"
      else
        @query = PagSeguro::Query.new(EMAIL, TOKEN, TRANSACTION_ID)
      end
    end

    it { expect(@query.transaction_id).to be_present }
    it { expect(@query.date).to be_present }
    it { expect(@query.id).to be_present }
    it { expect(@query.type).to be_present }
    it { expect(@query.status).to be_present }
    it { expect(@query.payment_method.type).to be_present }
    it { expect(@query.payment_method.code).to be_present }
    it { expect(@query.gross_amount).to be_present }
    it { expect(@query.discount_amount).to be_present }
    it { expect(@query.fee_amount).to be_present }
    it { expect(@query.net_amount).to be_present }
    it { expect(@query.extra_amount).to be_present }
    it { expect(@query.installment_count).to be_present }
    it { expect(@query.item_count).to be_present }
    it { expect(@query.items).to be_present }

    it "should have all required item attributes" do
      @query.items.each do |item|
        expect(item.id).to be_present
        expect(item.description).to be_present
        expect(item.amount).to be_present
        expect(item.quantity).to be_present
      end
    end

    it { expect(@query.sender.email).to be_present }
    it { expect(@query.shipping.type).to be_present }
  end

  describe "::find" do
    before :all do
      if EMAIL == "seu_email_cadastrado@nopagseguro.com.br"
        pending "You need to set your email for your PagSeguro account in spec/pag_seguro/integration/config.yml in order to run this spec"
      elsif TOKEN == "SEU_TOKEN_GERADO_NO_PAG_SEGURO"
        pending "You need to set your token for your PagSeguro account in spec/pag_seguro/integration/config.yml in order to run this spec"
      else
        @transactions = PagSeguro::Query.find(EMAIL, TOKEN, initial_date: 10.days.ago, final_date: Date.today)
        pending "You do not have any active transaction with your account in the past 30 days" unless @transactions.present?
      end
    end

    it "should return an array of Transactions" do
      @transactions.each do |transaction|
        expect(transaction).to be_an_instance_of(PagSeguro::Transaction)
        expect(transaction.id).to be_present
      end
    end
  end
end
