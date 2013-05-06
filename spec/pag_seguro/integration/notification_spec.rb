# encoding: utf-8
require 'spec_helper'

describe PagSeguro::Notification do
  before :all do
    if EMAIL == "seu_email_cadastrado@nopagseguro.com.br"
      pending "You need to set your email for your PagSeguro account in spec/pag_seguro/integration/config.yml in order to run this spec"
    elsif TOKEN == "SEU_TOKEN_GERADO_NO_PAG_SEGURO"
      pending "You need to set your token for your PagSeguro account in spec/pag_seguro/integration/config.yml in order to run this spec"
    elsif NOTIFICATION_CODE == "SEU_CODIGO_DE_NOTIFICACAO"
      pending "You need to set your notification token for your PagSeguro account in spec/pag_seguro/integration/config.yml in order to run this spec"
    else
      @notification = PagSeguro::Notification.new(EMAIL, TOKEN, NOTIFICATION_CODE)
    end
  end

  it { @notification.transaction_id.should be_present }
  it { @notification.date.should be_present }
  it { @notification.id.should be_present }
  it { @notification.type.should be_present }
  it { @notification.status.should be_present }
  it { @notification.payment_method.type.should be_present }
  it { @notification.payment_method.code.should be_present }
  it { @notification.gross_amount.should be_present }
  it { @notification.discount_amount.should be_present }
  it { @notification.fee_amount.should be_present }
  it { @notification.net_amount.should be_present }
  it { @notification.extra_amount.should be_present }
  it { @notification.installment_count.should be_present }
  it { @notification.item_count.should be_present }
  it { @notification.items.should be_present }

  it "should have all required item attributes" do
    @notification.items.each do |item|
      item.id.should be_present
      item.description.should be_present
      item.amount.should be_present
      item.quantity.should be_present
    end
  end

  it { @notification.sender.email.should be_present }
  it { @notification.shipping.type.should be_present }
end
