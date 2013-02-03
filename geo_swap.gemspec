# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'geo_swap/version'

Gem::Specification.new do |gem|
  gem.name          = "geo_swap"
  gem.version       = GeoSwap::VERSION
  gem.authors       = ["Ethan Vizitei"]
  gem.email         = ["ethan.vizitei@gmail.com"]
  gem.description   = %q{Simple utility functions for converting between coordinate systems (Lat/Long, UTM, USNG)}
  gem.summary       = %q{Simple utility functions for converting between coordinate systems (Lat/Long, UTM, USNG)}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake', '10.0.3'
  gem.add_development_dependency 'rspec', '2.12.0'
end
