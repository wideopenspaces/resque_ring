# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resqued/version'

Gem::Specification.new do |spec|
  spec.name          = 'resqued'
  spec.version       = Resqued::VERSION
  spec.authors       = ['Mila Jacob Stetser']
  spec.email         = ['jake@wideopenspac.es']
  spec.summary       = %q{Autoscaling pool manager for resque workers.}
  spec.description   = spec.summary + %q{ Enables dynamic worker pool management based on queue size, worker stats and other important variables. }
  spec.homepage      = 'https://github.com/wideopenspaces/resqued'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
