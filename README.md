# Fabric::Gateway

![Rspec Tests](https://github.com/EthicalIdentity/fabric-gateway-ruby/actions/workflows/rspec.yml/badge.svg) [![codecov](https://codecov.io/gh/EthicalIdentity/fabric-gateway-ruby/branch/master/graph/badge.svg?token=AXHQEN0R2R)](https://codecov.io/gh/EthicalIdentity/fabric-gateway-ruby) [![Maintainability](https://api.codeclimate.com/v1/badges/84bab9bb5911d3564df6/maintainability)](https://codeclimate.com/github/EthicalIdentity/fabric-gateway-ruby/maintainability) ![Gem](https://img.shields.io/gem/v/fabric-gateway) ![Downloads](https://img.shields.io/gem/dt/fabric-gateway)  [![GitHub license](https://img.shields.io/github/license/EthicalIdentity/fabric-gateway-ruby)](https://github.com/EthicalIdentity/fabric-gateway-ruby/blob/master/LICENSE.txt) 



Hyperledger Fabric Gateway gRPC SDK generated directly from protos found at: https://github.com/hyperledger/fabric-protos.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fabric-gateway'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fabric-gateway

### ISSUES

Note, there is an issue with the grpc library for MacOS (https://github.com/grpc/grpc/issues/28271). It results in a segfault in ruby when trying to make a connection. 

Workaround: Either run on linux or use a docker container as a workaround.

Will update to new version of grpc when fix is released.

## Usage

This is a alpha stage library. This library is barely working.

```
$ bin/console


def load_certs
  data_dir ='/your/certs/directory' # aka test-network/organizations
  files = [
      'peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem',
      'peerOrganizations/org1.example.com/users/Admin\@org1.example.com/msp/keystore/9f7c67dd4dd6562d258593c0d5011a3bff9121e65e67ff7fd3212919ae400a88_sk',
      'peerOrganizations/org1.example.com/users/Admin\@org1.example.com/msp/signcerts/cert.pem'
    ]
  files.map { |f| File.open(File.join(data_dir, f)).read }
end

# needed if you are connecting via a different dns name or IP address
client_opts = {
  channel_args: {
    GRPC::Core::Channel::SSL_TARGET => 'peer0.org1.example.com'
  }
}

user_identity = Fabric::Gateway::Identity.new(
  {
    username: "admin",
    affiliation: "org1.department1",
    mspid: 'Org1MSP',
    private_key: Fabric::Gateway.crypto_suite.key_from_pem(load_certs[1]),
    pem_certificate: load_certs[2],
  }
)

creds = GRPC::Core::ChannelCredentials.new(load_certs[0])
client=Gateway::Gateway::Stub.new('localhost:7051', creds, **client_opts)
proposal = Fabric::Gateway::Proposal.new(user_identity, {channel_id: 'your_channel', chaincode_id: 'basic', args: [ 'GetAllAssets' ]})

response = client.evaluate(Gateway::EvaluateRequest.new(channel_id: "your_channel", proposed_transaction: proposal.signed_proposal))

pp response
```

Please refer to the [full reference documentation](https://rubydoc.info/github/EthicalIdentity/fabric-gateway-ruby) for complete usage information.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To rebuild the proto code, run the regenerate script:

```
$ bin/regenerate
```

Effort has been made to follow the design patterns and naming convention where possible from the official [Hyperledger Fabric Gateway SDK](https://github.com/hyperledger/fabric-gateway) while at the same time producing an idiomatic ruby gem. Our intention is to produce a gem that would be compatible with the documentation of the official SDK while natural to use for a seasoned ruby developer.

## Development References & Resources

These are the libraries and knowledge necessary for developing this gem:

* gRPC - [gRPC Intro](https://grpc.io/docs/what-is-grpc/introduction/) / [gRPC on ruby](https://grpc.io/docs/languages/ruby/)
* Protocol Buffers (Protobuf) - [overview](https://developers.google.com/protocol-buffers/docs/proto3) / [ruby reference](https://developers.google.com/protocol-buffers/docs/reference/ruby-generated)
* [Hyperledger Fabric Protocol Specifications](https://openblockchain.readthedocs.io/en/latest/protocol-spec/) 
* [Hyperledger Fabric Gateway Overview](https://hyperledger-fabric.readthedocs.io/en/latest/gateway.html) / [Fabric Gateway RFC](https://hyperledger.github.io/fabric-rfcs/text/0000-fabric-gateway.html)
  
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ethicalidentity/fabric-gateway. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ethicalidentity/fabric-gateway/blob/master/CODE_OF_CONDUCT.md).

## TODO

~~everything~~

- [x] Add license
- [x] Add ChangeLog
- [x] Create Gem
- [x] Add testing & CI/CD
- [x] Add rubocop and linting
- [ ] Add usage instructions
- [x] Setup auto-generation of API docs on rubydoc.info
- [ ] Abstract connection and calls such that the protos aren't being interacted directly
- [ ] Implement, Document & Test Endorse
- [ ] Implement, Document & Test Submit
- [ ] Implement, Document & Test CommitStatus
- [ ] Implement, Document & Test ChaincodeEvents
- [ ] Implement off-line signing - https://github.com/hyperledger/fabric-gateway/blob/1e4a926ddb98ec8ee969da3fc1500642ab389d01/node/src/contract.ts#L63 
- [ ] Consider adding integration tests against blockchain; might be a ton of stuff to setup
- [ ] Support for offline transaction signing - https://github.com/hyperledger/fabric-gateway/blob/cf78fc11a439ced7dfd2f9b55886c55c73119b25/pkg/client/offlinesign_test.go




## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Portions of the code are from https://github.com/kirshin/hyperledger-fabric-sdk.

## Code of Conduct

Everyone interacting in the Fabric::Gateway project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ethicalidentity/fabric-gateway/blob/master/CODE_OF_CONDUCT.md).
