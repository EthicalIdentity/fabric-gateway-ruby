# frozen_string_literal: true

require_relative 'lib/fabric/version'

Gem::Specification.new do |spec|
  spec.name          = 'fabric-gateway'
  spec.version       = Fabric::VERSION
  spec.authors       = ['Jonathan Chan']
  spec.email         = ['jonathan.chan@ethicalidentity.com']

  spec.summary       = 'Hyperledger Fabric Gateway SDK'
  spec.description   = 'Ruby port of the Hyperledger Fabric Gateway SDK'
  spec.homepage      = 'https://github.com/ethicalidentity/fabric-gateway-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ethicalidentity/fabric-gateway-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/EthicalIdentity/fabric-gateway-ruby/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency('google-protobuf', '~> 3.24', '>= 3.24.4')
  spec.add_dependency('grpc', '~> 1.42')
  spec.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
