# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pag_seguro/version"

Gem::Specification.new do |s|
  s.name        = "pag_seguro"
  s.version     = PagSeguro::VERSION
  s.authors     = ["Stefano Diem Benatti"]
  s.email       = ["stefano.diem@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A ruby gem to handle PagSeguro's API version 2}
  s.description = %q{A ruby gem to handle PagSeguro's API version 2}

  s.rubyforge_project = "pag_seguro"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
