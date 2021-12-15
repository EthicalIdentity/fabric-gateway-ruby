# Fabric::Gateway

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

## Usage

This is a pre-alpha library. None of the code has been tested or confirmed working yet.


non-working notes...

```
$ bin/console

# how in the world do we grab a certificate and connect to the peer properly?
stub=Gateway::Gateway::Stub.new('localhost:7051', :this_channel_is_insecure)
stub.submit(Gateway::SubmitRequest.new(transaction_id: "123", channel_id: "2", prepared_transaction: Common::Envelope.new()))

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To rebuild the proto code, run the regenerate script:

```
$ bin/regenerate
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ethicalidentity/fabric-gateway. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ethicalidentity/fabric-gateway/blob/master/CODE_OF_CONDUCT.md).

## TODO

~~everything~~

- [x] Add license
- [x] Add ChangeLog
- [ ] Create Gem
- [ ] Add usage instructions
- [ ] Add testing?


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fabric::Gateway project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ethicalidentity/fabric-gateway/blob/master/CODE_OF_CONDUCT.md).
