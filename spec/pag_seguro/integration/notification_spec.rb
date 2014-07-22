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

  it { expect(@notification.transaction_id).to be_present }
  it { expect(@notification.date).to be_present }
  it { expect(@notification.id).to be_present }
  it { expect(@notification.type).to be_present }
  it { expect(@notification.status).to be_present }
  it { expect(@notification.payment_method.type).to be_present }
  it { expect(@notification.payment_method.code).to be_present }
  it { expect(@notification.gross_amount).to be_present }
  it { expect(@notification.discount_amount).to be_present }
  it { expect(@notification.fee_amount).to be_present }
  it { expect(@notification.net_amount).to be_present }
  it { expect(@notification.extra_amount).to be_present }
  it { expect(@notification.installment_count).to be_present }
  it { expect(@notification.item_count).to be_present }
  it { expect(@notification.items).to be_present }

  it "should have all required item attributes" do
    @notification.items.each do |item|
      expect(item.id).to be_present
      expect(item.description).to be_present
      expect(item.amount).to be_present
      expect(item.quantity).to be_present
    end
  end

  it { expect(@notification.sender.email).to be_present }
  it { expect(@notification.shipping.type).to be_present }
end
