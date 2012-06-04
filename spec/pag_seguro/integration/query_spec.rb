# encoding: utf-8
require 'spec_helper'

describe PagSeguro::Query do
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
  
  it { @query.transaction_id.should be_present }
  it { @query.date.should be_present }
  it { @query.id.should be_present }
  it { @query.type.should be_present }
  it { @query.status.should be_present }
  it { @query.payment_method.type.should be_present }
  it { @query.payment_method.code.should be_present }
  it { @query.gross_amount.should be_present }
  it { @query.discount_amount.should be_present }
  it { @query.fee_amount.should be_present }
  it { @query.net_amount.should be_present }
  it { @query.extra_amount.should be_present }
  it { @query.installment_count.should be_present }
  it { @query.item_count.should be_present }
  it { @query.items.should be_present }

  it "should have all required item attributes" do
    @query.items.each do |item|
      item.id.should be_present
      item.description.should be_present
      item.amount.should be_present
      item.quantity.should be_present
    end
  end
  
  it { @query.sender.email.should be_present }
  it { @query.shipping.type.should be_present }
end
