require 'amqp_mailer/version'

module AmqpMailer
  autoload :DeliveryMethod, 'amqp_mailer/delivery_method'
  autoload :NotificationDispatcher, 'amqp_mailer/notification_dispatcher'
  autoload :Configuration, 'amqp_mailer/configuration'

  def self.configuration
    @configration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end

require 'amqp_mailer/railtie' if defined?(Rails::Railtie)
