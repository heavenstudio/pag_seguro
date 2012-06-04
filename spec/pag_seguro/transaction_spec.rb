# encoding: utf-8

require 'spec_helper'

describe PagSeguro::Transaction do
  let(:transaction){ PagSeguro::Transaction.new(transaction_xml) }
  
  it_behaves_like "a transaction"
end