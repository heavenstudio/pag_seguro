# encoding: utf-8

require 'spec_helper'

describe PagSeguro::Query do
  describe :query_transaction do
    before{ RestClient.stub(get: transaction_xml) }
    let(:transaction){ PagSeguro::Query.query_transaction("mail", "token", "trans_code") }
    subject{ PagSeguro::Query.query_transaction("mail", "token", "trans_code").class }

    it_behaves_like "a transaction"
  end

  describe :query_transaction_history do
  end

  describe :query_abandoned_transactions do
  end
end
