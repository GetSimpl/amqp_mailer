require 'amqp_mailer/delivery_method'

describe AmqpMailer::DeliveryMethod do
  it 'it\'s instance responds to settings' do
    AmqpMailer.configure do |config|
      config.amqp_url = 'amqp://boggart'
      config.notifications_topic_exchange = 'quidditch'
      config.service_id = 'daily-prophet'
    end

    inst = AmqpMailer::DeliveryMethod.new

    expect(inst.settings).to eq({})
  end
end
