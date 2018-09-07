require 'bunny'

module AmqpMailer
  class NotificationDispatcher
    def perform(contents, use_priority_queue)
      Bunny.run(AmqpMailer.configuration.amqp_url) do |connection|
        channel = connection.create_channel
        exchange = Bunny::Exchange.new(channel, :topic, AmqpMailer.configuration.notifications_topic_exchange, durable: true)
        routing_key = use_priority_queue ? 'priority.email' : 'normal.email'
        exchange.publish(contents.to_json, routing_key: routing_key)
      end
    rescue => e
      Rails.logger.error(e.message) if defined?(Rails)
    end
  end
end
