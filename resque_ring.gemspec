# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque_ring/version'

Gem::Specification.new do |s|
  s.name          = 'resque_ring'
  s.version       = ResqueRing::VERSION
  s.authors       = ['Mila Jacob Stetser']
  s.email         = ['jake@wideopenspac.es']
  s.summary       = %q{Autoscaling pool manager for resque workers.}
  s.description   = s.summary + %q{ Enables dynamic worker pool management based on queue size, worker stats and other important variables. }
  s.homepage      = 'https://github.com/wideopenspaces/resque_ring'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-minitest'
  s.add_development_dependency 'minitest', '~> 5.0.0'
  s.add_development_dependency 'minitest-spec-context'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'mocha', '0.13.3'
  s.add_development_dependency 'mock_redis'
  s.add_development_dependency 'simplecov', '~> 0.8.1'

  s.add_dependency 'resque', ['>= 1.15.0', '< 2.0']
  s.add_dependency 'madhattr', '0.5.0'
  s.add_dependency 'yambol', '1.0.0'
  s.add_dependency 'childprocess'
end
