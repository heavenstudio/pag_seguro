$: << "lib/pag_seguro"

# Core Ruby Libraries
require "net/https"
require "uri"

# Third party gems
require "active_model"
require "nokogiri"
require "haml"

# PagSeguro classes
require "item"
require "payment"
require "sender"
require "shipping"

# Version
require "version"

module PagSeguro
end
