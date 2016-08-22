# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atlassian/jwt/version'

Gem::Specification.new do |spec|
  spec.name          = "atlassian-jwt"
  spec.version       = Atlassian::Jwt::VERSION
  spec.authors       = ["Spike Ilacqua", "Seb Ruiz"]
  spec.email         = ["spike@6kites.com", "sruiz@atlassian.com"]

  spec.summary       = %q{Encode and decode JWT tokens for use with the Atlassian Connect REST APIs.}
  spec.description   = %q{This gem simplifies generating the claims need to authenticate with the Atlassian Connect REST APIs.}
  spec.homepage      = "https://bitbucket.org/atlassian/atlassian-jwt-ruby"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'jwt', '~> 1.5'
  spec.add_development_dependency 'json', '~> 1.8'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
