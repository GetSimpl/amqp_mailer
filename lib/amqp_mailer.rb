require 'amqp_mailer/version'
require 'amqp_mailer/delivery_method'
require 'amqp_mailer/notification_dispatcher'
require 'amqp_mailer/configuration'

module AmqpMailer
  def self.configuration
    @configration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end

require 'amqp_mailer/railtie' if defined?(Rails::Railtie)
