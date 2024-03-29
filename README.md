# Errordeck

[![Gem Version](https://badge.fury.io/rb/errordeck.svg)](https://badge.fury.io/rb/errordeck)

Ruby client for [Errordeck](https://www.errordeck.com). Errordeck is a error monitoring service that helps you find the errors in a easy and fun way.

## Features

- [x] Send errors to Errordeck
- [x] Send user context to Errordeck
- [x] Send tags to Errordeck
- [x] Send environment to Errordeck
- [x] Send platform to Errordeck
- [x] Send stacktrace to Errordeck
- [x] Send context/file content (around the error) to Errordeck
- [ ] Send breadcrumbs to Errordeck
- [ ] Send release to Errordeck
- [ ] Send source maps to Errordeck
- [x] Send extra data to Errordeck
- [x] Send fingerprint to Errordeck
- [x] Send level to Errordeck
- [x] Send server name to Errordeck
- [x] Send modules to Errordeck
- [x] Send request data to Errordeck
- [x] Send user data to Errordeck

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'errordeck'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install errordeck

## Usage

You can set up the client in the following ways:

Set the token, project_id, environment, release and dist in the configuration:
```ruby
Errordeck.configure do |config|
  config.token = "_r-3A7egL7uMSFASfdRodzxxxAQo"
  config.project_id = "1"
  config.environment = "development" # optional - if not set, it will be set to Rails.env
  config.release = "0.0.0" # optional
  config.dist = "0.0.0" # optional
end
```

And then send an error:
```ruby
begin
  raise "test"
rescue StandardError => e
  Errordeck.capture(e)
end
``` 

### Send user context

```ruby
begin
  raise "test"
rescue StandardError => e
  Errordeck.capture(e, user: { id: 1})
end
``` 

### Use wrap to wrap errors with the context

```ruby
begin
  raise "test"
rescue StandardError => e
  Errordeck.wrap do |wrap|
    wrap.user_context = { id: 1 }
    wrap.tags_context = { tag: "tag" }
    wrap.context = { context: "context" }
    wrap.capture(e) # needs to be last
  end
end
``` 

### Using with Rails

Rails will add the exceptionhandler automatically, so you don't need to do anything. You can still use above example to fill context and such. And the config is needed.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/errordeck/errordeck-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/errordeck/errordeck-ruby/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Errordeck::Ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/errordeck/errordeck-ruby/blob/master/CODE_OF_CONDUCT.md).
