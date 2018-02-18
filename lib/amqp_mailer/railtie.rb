module AmqpMailer
  class Railtie < Rails::Railtie
    initializer "amqp_mailer.add_delivery_method" do
      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.add_delivery_method(
            :amqp,
            AmqpMailer::DeliveryMethod
        )
      end
    end
  end
end