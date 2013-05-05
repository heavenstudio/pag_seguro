require "spec_helper"

class MockResponse
  def code
    10000
  end

  def body
    " error description"
  end
end

describe PagSeguro::Errors::UnknownError do
  it "should be able to raise an unknown error" do
    lambda { raise PagSeguro::Errors::UnknownError.new(MockResponse.new) }.should raise_error(PagSeguro::Errors::UnknownError, "Unknown response code (10000):\n error description")
  end
end
