require "spec_helper"

def invalid_data_xml
<<XML
<errors>
  <error>
    <code>404</code>
    <message>Not Found</message>
  </error>
  <error>
    <code>422</code>
    <message>Unauthorized</message>
  </error>
</errors>
XML
end

describe PagSeguro::Errors::InvalidData do
  it "should be able to parse an error xml and raise the error codes" do
    lambda { raise PagSeguro::Errors::InvalidData.new(invalid_data_xml) }.should raise_error(PagSeguro::Errors::InvalidData, "404: Not Found\n422: Unauthorized\n")
  end
end
