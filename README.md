# AmqpMailer

This gem provides an easy way to send emails using notifications service.   

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'amqp_mailer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install amqp_mailer

## Usage

Change action mailer's delivery method to `:amqp`

```ruby
config.action_mailer.delivery_method = :amqp
```

Configure AmqpMailer by setting required parameters

```ruby
AmqpMailer.configure do |config|
  config.amqp_url = ENV['AMQP_URL']
  config.notifications_topic_exchange = ENV['NOTIFICATIONS_TOPIC_EXCHANGE']
end
```

Pass phone number in addition to other parameters to `mail()` method of ActionMailer 

```ruby
mail(to: 'woody@pixar.com', subject: 'To Infinity and Beyond', 'X-SIMPL-PHONE-NUMBER': phone_number)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

Some useful resources:
- http://guides.rubygems.org/make-your-own-gem/
- http://bundler.io/v1.12/guides/creating_gem.html

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GetSimpl/amqp_mailer.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
