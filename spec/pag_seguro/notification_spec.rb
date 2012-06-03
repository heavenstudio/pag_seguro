# encoding: utf-8

require 'spec_helper'

describe PagSeguro::Notification do
  before do
    transaction_xml_mock = File.open( File.expand_path( File.dirname(__FILE__) + '/../fixtures/transaction.xml') )
    RestClient.stub(:get){ transaction_xml_mock }
    @notification = PagSeguro::Notification.new("mail", "token", "not_code")
  end

  it "should have an id" do
    @notification.id.should == "REF1234"
  end
end
