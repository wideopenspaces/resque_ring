# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resqued/version'

Gem::Specification.new do |s|
  s.name          = 'resqued'
  s.version       = Resqued::VERSION
  s.authors       = ['Mila Jacob Stetser']
  s.email         = ['jake@wideopenspac.es']
  s.summary       = %q{Autoscaling pool manager for resque workers.}
  s.description   = s.summary + %q{ Enables dynamic worker pool management based on queue size, worker stats and other important variables. }
  s.homepage      = 'https://github.com/wideopenspaces/resqued'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-minitest'
  s.add_development_dependency 'minitest', '~> 4.7.5'
  s.add_development_dependency 'minitest-spec-context'
  s.add_development_dependency 'pry'

  s.add_dependency 'resque', ['>= 1.15.0', '< 2.0']
end
