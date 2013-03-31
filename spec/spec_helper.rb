require 'simplecov'
SimpleCov.start do
  add_filter "spec/"
end

require 'yaml'
require File.dirname(__FILE__) + "/../lib/pag_seguro"
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}
require 'shoulda-matchers'

config = YAML.load_file(File.dirname(__FILE__) + "/pag_seguro/integration/config.yml")
EMAIL = config["email"]
TOKEN = config["token"]
NOTIFICATION_CODE = config["notification_code"]
TRANSACTION_ID = config["transaction_id"]

class HaveAttributeAccessor
  def initialize(attribute)
    @attribute = attribute
  end
  
  def matches?(target)
    @target = target
    @target.respond_to?(:"#{@attribute}").should == true
    @target.respond_to?(:"#{@attribute}=").should == true
  end
  
  def failure_message
    "expected #{@target.inspect} to have '#{@expected}' attribute accessor"
  end
  
  def negative_failure_message
    "expected #{@target.inspect} not to have '#{@expected}' attribute accessor"
  end
end

def have_attribute_accessor(attribute)
  HaveAttributeAccessor.new(attribute)
end