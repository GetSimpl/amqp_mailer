require 'bunny'

module AmqpMailer
  class NotificationDispatcher
    def perform(contents)
      Bunny.run(AmqpMailer.configuration.amqp_url) do |connection|
        channel = connection.create_channel
        exchange = Bunny::Exchange.new(channel, :topic, AmqpMailer.configuration.notifications_topic_exchange, durable: true)
        exchange.publish(contents.to_json, routing_key: 'priority.email')
      end
    rescue => e
      Rails.logger.error(e.message) if defined?(Rails)
    end
  end
end
