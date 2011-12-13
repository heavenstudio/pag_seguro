require 'spec_helper'

describe PagSeguro::Payment do
  it "should have a base url to 'ws.pagseguro.uol.com.br/v2/checkout'" do
    PagSeguro::Payment::BASE_URL.should == 'ws.pagseguro.uol.com.br/v2/checkout'
  end
end