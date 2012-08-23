# encoding: utf-8

require 'spec_helper'

describe PagSeguro::Query do
  before { PagSeguro::Query.any_instance.stub(:transaction_data => transaction_data) }
  let(:transaction){ PagSeguro::Query.new("mail", "token", "trans_code") }

  it_behaves_like "a transaction"
end
