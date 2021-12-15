require_relative 'lib/fabric/gateway/version'

Gem::Specification.new do |spec|
  spec.name          = "fabric-gateway"
  spec.version       = Fabric::Gateway::VERSION
  spec.authors       = ["Jonathan Chan"]
  spec.email         = ["jonathan.chan@ethicalidentity.com"]

  spec.summary       = %q{Hyperledger Fabric Gateway gRPC SDK}
  spec.description   = %q{Hyperledger Fabric Gateway gRPC SDK generated directly from protos found at: https://github.com/hyperledger/fabric-protos.}
  spec.homepage      = "https://github.com/ethicalidentity/fabric-gateway-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = 'https://rubygems.org'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ethicalidentity/fabric-gateway-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/EthicalIdentity/fabric-gateway-ruby/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency('google-protobuf', '>= 3.19.1')
  spec.add_dependency('grpc', '~> 1.42')
end
