# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faye-extensions/version'

Gem::Specification.new do |gem|
  gem.name          = "faye-extensions"
  gem.version       = FayeExtensions::VERSION
  gem.authors       = ["Matthew Robertson"]
  gem.email         = ["matthew@medeo.ca"]
  gem.description   = %q{Faye Ruby extensions for Medeo's real-time app.'}
  gem.summary       = %q{Faye Ruby extensions for Medeo's real-time app.}
  gem.homepage      = "https://github.com/medeo/faye-extensions"

  gem.files         = `git ls-files`.split($/)
  # gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec'
  gem.add_dependency 'faye'
  gem.add_dependency 'eventmachine'
end
