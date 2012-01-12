module PagSeguro
  module Errors
    class InvalidData < Exception
      def initialize(response_xml)
        err_msg = Nokogiri::XML(response_xml).css("errors error").inject("") do |acc, node|
          acc + "#{node.css('code').first.content}: #{node.css('message').first.content}\n"
        end
        super(err_msg)
      end
    end
  end
end