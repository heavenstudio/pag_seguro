# encoding: utf-8

require 'spec_helper'

describe PagSeguro::Notification do
  before { PagSeguro::Notification.any_instance.stub(transaction_data: transaction_data) }
  let(:transaction){ PagSeguro::Notification.new("mail", "token", "not_code") }
  subject{ PagSeguro::Notification }

  it_behaves_like "a transaction"
end
