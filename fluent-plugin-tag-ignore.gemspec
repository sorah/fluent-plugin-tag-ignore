# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent-plugin-tag-ignore/version'

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-tag-ignore"
  spec.version       = Fluent::TagIgnoreOutput::VERSION
  spec.authors       = ["Shota Fukumori (sora_h)"]
  spec.email         = ["her@sorah.jp"]
  spec.description   = %q{Plugin for fluentd, this allows you to specify ignore patterns for match.}
  spec.summary       = %q{this fluentd-plugin allows you to specify ignore patterns for match directive.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fluentd", "~> 0.10"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", '~> 2.14.1'
end
