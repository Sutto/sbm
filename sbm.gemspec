# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sbm/version'

Gem::Specification.new do |spec|
  spec.name          = "sbm"
  spec.version       = SBM::VERSION
  spec.authors       = ["Darcy Laycock"]
  spec.email         = ["sutto@sutto.net"]
  spec.description   = %q{Tools for managed simple batches across N nodes.}
  spec.summary       = %q{Built on redis, provides a basic set of tools that let you process tasks in parallel across N nodes.}
  spec.homepage      = "https://github.com/Sutto"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
