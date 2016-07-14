# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/deploy_locker/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-deploy-locker"
  spec.version       = Capistrano::AuthorizedKeys::VERSION
  spec.authors       = ["Stephen Roos"]
  spec.email         = ["sroos@careerarc.com"]

  spec.summary       = %q{Capistrano tasks for preventing multiple simultaneous deploys}
  spec.description   = %q{Capistrano tasks for preventing multiple simultaneous deploys}
  spec.homepage      = "https://www.github.com/CareerArcGroup/capistrano-deploy-locker"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", ">= 3.1"
  spec.add_dependency "redis", ">= 2.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
