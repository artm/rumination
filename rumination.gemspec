# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rumination/version"

Gem::Specification.new do |spec|
  spec.name          = "rumination"
  spec.version       = Rumination::VERSION
  spec.authors       = ["Artem Baguinski"]
  spec.email         = ["abaguinski@depraktijkindex.nl"]

  spec.summary       = %q{development utilities}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/artm/rumination"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "activesupport"
  spec.add_dependency "activemodel"
  spec.add_dependency "railties"
  spec.add_dependency "dotenv"
  spec.add_dependency "highline"
  spec.add_dependency "newrelic_rpm"
end
