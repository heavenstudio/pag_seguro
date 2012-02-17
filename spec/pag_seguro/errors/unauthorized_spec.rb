require "spec_helper"

describe PagSeguro::Errors::Unauthorized do
  it "should be able to raise an unauthorized error" do
    lambda { raise PagSeguro::Errors::Unauthorized.new }.should raise_error(PagSeguro::Errors::Unauthorized, "Credentials provided (e-mail and token) failed to authenticate")
  end
end
