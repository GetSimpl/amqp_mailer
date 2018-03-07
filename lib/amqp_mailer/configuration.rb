module AmqpMailer
  class Configuration
    attr_accessor :amqp_url, :notifications_topic_exchange, :service_id
  end
end
