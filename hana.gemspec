# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hana/version"

Gem::Specification.new do |s|
  s.name        = "hana"
  s.version     = Hana::VERSION
  s.authors     = ["Chris Paraiso"]
  s.email       = ["cparaiso@unicon.net"]
  s.homepage    = "http://chrisparaiso.com"
  s.summary     = "Automation toolset for Uni."
  s.description = "hana do_todays_work"

  s.rubyforge_project = "hana"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "curb"
  s.add_runtime_dependency "nokogiri"
end
