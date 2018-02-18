require 'spec_helper'
require 'securerandom'
require 'mail'
require 'active_support'
require 'active_support/core_ext'

describe AmqpMailer do
  before(:each) do
    @verification_id = SecureRandom.uuid
    allow(SecureRandom).to receive(:uuid).and_return(@verification_id)

    AmqpMailer.configure do |config|
      config.amqp_url = 'amqp://boggart'
      config.notifications_topic_exchange = 'quidditch'
    end
  end

  it 'sends amqp message using notification dispatcher' do
    mail = Mail::Message.new
    mail['from'] = 'Professor Snape <severus@hogwarts.edu.uk>'
    mail['to'] = 'albus@hogwarts.edu.uk'
    mail['subject'] = 'The dark lord is back'
    mail['body'] = 'He - who must not be named - is back'
    mail['X-SIMPL-PHONE-NUMBER'] = '9999999999'

    expected_payload = {
        content: 'He - who must not be named - is back',
        subject: 'The dark lord is back',
        from_name: 'Professor Snape',
        from_email: 'severus@hogwarts.edu.uk',
        to_email: 'albus@hogwarts.edu.uk',
        phone_number: '9999999999',
        service_id: 'verification-service',
        notification_type: 'email',
        notification_id: @verification_id
    }

    expect_any_instance_of(AmqpMailer::NotificationDispatcher).to receive(:perform).with(expected_payload)

    AmqpMailer::DeliveryMethod.new.deliver!(mail)
  end

  context 'when phone number is not passed' do
    it 'sets phone number to a default value' do
      mail = Mail::Message.new
      mail['from'] = 'Professor Snape <severus@hogwarts.edu.uk>'
      mail['to'] = 'albus@hogwarts.edu.uk'
      mail['subject'] = 'The dark lord is back'
      mail['body'] = 'He - who must not be named - is back'

      expected_payload = {
          content: 'He - who must not be named - is back',
          subject: 'The dark lord is back',
          from_name: 'Professor Snape',
          from_email: 'severus@hogwarts.edu.uk',
          to_email: 'albus@hogwarts.edu.uk',
          phone_number: AmqpMailer::DeliveryMethod::DEFAULT_SIMPL_PHONE_NUMBER,
          service_id: 'verification-service',
          notification_type: 'email',
          notification_id: @verification_id
      }

      expect_any_instance_of(AmqpMailer::NotificationDispatcher).to receive(:perform).with(expected_payload)

      AmqpMailer::DeliveryMethod.new.deliver!(mail)
    end
  end

  context 'when amqp url in missing' do
    it 'raises error' do
      AmqpMailer.configuration.amqp_url = nil
      mail = Mail::Message.new

      expect {AmqpMailer::DeliveryMethod.new.deliver!(mail)}.to \
      raise_error(AmqpMailer::DeliveryMethod::MissingConfiguration, 'AMQP URL is missing')
    end
  end

  context 'when notifications_topic_exchange in missing' do
    it 'raises error' do
      AmqpMailer.configuration.notifications_topic_exchange = ''
      mail = Mail::Message.new

      expect {AmqpMailer::DeliveryMethod.new.deliver!(mail)}.to \
      raise_error(AmqpMailer::DeliveryMethod::MissingConfiguration, 'Notifications topic exchange is missing')
    end
  end
end
