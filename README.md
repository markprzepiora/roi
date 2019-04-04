# Roi [![Build Status](https://travis-ci.org/markprzepiora/roi.svg?branch=master)](https://travis-ci.org/markprzepiora/roi) [![Test Coverage](https://api.codeclimate.com/v1/badges/bec5a607a62ba4cacbea/test_coverage)](https://codeclimate.com/github/markprzepiora/roi/test_coverage)

Roi is a spiritual-reimplementation of [joi](https://github.com/hapijs/joi) in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'roi'
```

And then execute:

    $ bundle

## Basic Usage

Complete example (valid object):

```ruby
update_user_schema = Roi.define do
  object({
    email: string.email,
    name: string.present,
    birth_year: int.min(1900).max(2013),
    receive_emails: array(enum('transactional', 'marketing')).unique,
    company: object({
      name: string.present,
    }).or_nil,
  })
end

passing_payload_1 = {
  email: "foo@example.com",
  name: "Foo Barr",
  birth_year: 1985,
  receive_emails: ['transactional'],
  company: { name: "ACME Co." },
  an_extra_field: 123,
}

update_user_schema.validate(passing_payload_1).ok? # => true
update_user_schema.validate(passing_payload_1).value
# => {
#   email: "foo@example.com",
#   name: "Foo Barr",
#   birth_year: 1985,
#   receive_emails: ['transactional'],
#   company: { name: "ACME Co." },
# }
```

And an invalid object:

```ruby
failing_payload_1 = {
  company: { name: nil },
}
update_user_schema.validate(failing_payload_1).ok? # => false
update_user_schema.validate(failing_payload_1).errors.as_json
# => [
#      {
#        validator_name: 'string',
#        path: [:company, :name],
#        message: 'must be a String',
#      }
#    ]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/markprzepiora/roi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Roi project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/markprzepiora/roi/blob/master/CODE_OF_CONDUCT.md).
