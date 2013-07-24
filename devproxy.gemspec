# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devproxy/version'

Gem::Specification.new do |gem|
  gem.name          = "devproxy"
  gem.version       = Devproxy::VERSION
  gem.authors       = ["Adam Bozanich"]
  gem.email         = ["adam.boz@gmail.com"]
  gem.summary       = %q{https://devproxy.io client gem}
  gem.description   = %q{https://devproxy.io client gem}
  gem.homepage      = "https://github.com/boz/devproxy"
  gem.license       = "MIT"

  gem.add_dependency "net-ssh", "~> 2.6.7"
  gem.add_development_dependency "rspec"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
