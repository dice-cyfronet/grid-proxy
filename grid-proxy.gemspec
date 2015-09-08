# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grid-proxy/version'

Gem::Specification.new do |spec|
  spec.name          = "grid-proxy"
  spec.version       = GP::VERSION
  spec.authors       = ["Marek Kasztelnik"]
  spec.email         = ["mkasztelnik@gmail.com"]
  spec.description   = %q{Grid proxy utils}
  spec.summary       = %q{Grid proxy utils}
  spec.homepage      = "https://gitlab.dev.cyfronet.pl/commons/grid-proxy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
