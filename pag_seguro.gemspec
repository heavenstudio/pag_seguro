# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pag_seguro/version"

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "pag_seguro"
  s.version     = PagSeguro::VERSION
  s.authors     = ["Stefano Diem Benatti"]
  s.email       = ["stefano.diem@gmail.com"]
  s.homepage    = "http://github.com/heavenstudio/pag_seguro"
  s.summary     = %q{A ruby gem to handle PagSeguro's API version 2}
  s.required_ruby_version = '>= 1.9.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.has_rdoc      = false
  
  s.add_dependency('activemodel')
  s.add_dependency('activesupport')
  s.add_dependency('haml', '!= 3.1.5')
  s.add_dependency('nokogiri')
  s.add_dependency('rest-client', '~> 1.6.7')
end
