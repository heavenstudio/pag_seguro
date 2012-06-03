# encoding: utf-8

require 'spec_helper'

describe PagSeguro::Query do
  before do
    transaction_xml_mock = File.open( File.expand_path( File.dirname(__FILE__) + '/../fixtures/transaction.xml') )
    RestClient.stub(:get){ transaction_xml_mock }
    @query = PagSeguro::Query.new("mail", "token", "trans_code")
  end

  it "should have an id" do
    @query.id.should == "REF1234"
  end
end
