require 'simplecov'
SimpleCov.start do
  add_filter "spec/"
end

require 'yaml'
require File.dirname(__FILE__) + "/../lib/pag_seguro"
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}
require 'shoulda-matchers'
require 'factory_girl'

include FactoryGirl::Syntax::Methods
FactoryGirl.find_definitions

config = YAML.load_file(File.dirname(__FILE__) + "/pag_seguro/integration/config.yml")
EMAIL = config["email"]
TOKEN = config["token"]
NOTIFICATION_CODE = config["notification_code"]
TRANSACTION_ID = config["transaction_id"]

RSpec::Matchers.define :have_attribute_accessor do |attribute|
  match do |actual|
    actual.respond_to?(attribute) && actual.respond_to?("#{attribute}=")
  end

  description do
    "have attr_accessor :#{attribute}"
  end
end