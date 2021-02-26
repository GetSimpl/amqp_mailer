require 'spec_helper'
require 'securerandom'
require 'mail'
require 'json'

describe AmqpMailer do
  before(:each) do
    @dummy_notification_id = SecureRandom.uuid
    allow(SecureRandom).to receive(:uuid).and_return(@dummy_notification_id)

    AmqpMailer.configure do |config|
      config.amqp_url = 'amqp://boggart'
      config.notifications_topic_exchange = 'quidditch'
      config.service_id = 'daily-prophet'
    end
  end

  it 'sends amqp message using notification dispatcher' do
    mail = Mail::Message.new
    mail['from'] = 'Professor Snape <severus@hogwarts.edu.uk>'
    mail['to'] = 'A B <albus@hogwarts.edu.uk>'
    mail['subject'] = 'The dark lord is back'
    mail['body'] = 'He - who must not be named - is back'
    mail['X-SIMPL-USER-ID'] = 'some-id'
    mail['X-SIMPL-PHONE-NUMBER'] = '9999999999'
    mail['use_priority_queue'] = true
    expected_payload = {
        content: 'He - who must not be named - is back',
        subject: 'The dark lord is back',
        from_name: 'Professor Snape',
        from_email: 'severus@hogwarts.edu.uk',
        to: [{email: "albus@hogwarts.edu.uk", name: "A B"}],
        preserve_recipients: false,
        user_id: 'some-id',
        phone_number: '9999999999',
        service_id: 'daily-prophet',
        notification_type: 'email',
        notification_id: @dummy_notification_id,
    }

    expect_any_instance_of(AmqpMailer::NotificationDispatcher).to receive(:perform).with(expected_payload, true)

    AmqpMailer::DeliveryMethod.new.deliver!(mail)
  end

  it 'handles to email is invalid' do
    mail = Mail::Message.new
    mail['from'] = 'Professor Snape <severus@hogwarts.edu.uk>'
    mail['to'] = 'A B <>'
    mail['subject'] = 'The dark lord is back'
    mail['body'] = 'He - who must not be named - is back'
    mail['X-SIMPL-USER-ID'] = 'some-id'
    mail['X-SIMPL-PHONE-NUMBER'] = '9999999999'
    mail['use_priority_queue'] = true
    expected_payload = {
        content: 'He - who must not be named - is back',
        subject: 'The dark lord is back',
        from_name: 'Professor Snape',
        from_email: 'severus@hogwarts.edu.uk',
        to: [],
        preserve_recipients: false,
        user_id: 'some-id',
        phone_number: '9999999999',
        service_id: 'daily-prophet',
        notification_type: 'email',
        notification_id: @dummy_notification_id,
    }

    expect_any_instance_of(AmqpMailer::NotificationDispatcher).to receive(:perform).with(expected_payload, true)

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
          to: [{email: "albus@hogwarts.edu.uk", name: nil}],
          preserve_recipients: false,
          user_id: AmqpMailer::DeliveryMethod::DEFAULT_SIMPL_USER_ID,
          phone_number: AmqpMailer::DeliveryMethod::DEFAULT_SIMPL_PHONE_NUMBER,
          service_id: 'daily-prophet',
          notification_type: 'email',
          notification_id: @dummy_notification_id
      }

      expect_any_instance_of(AmqpMailer::NotificationDispatcher).to receive(:perform).with(expected_payload, false)

      AmqpMailer::DeliveryMethod.new.deliver!(mail)
    end
  end

  context 'for preserve_recipients' do
    before do
      @mail = Mail::Message.new
      @mail['from'] = 'Professor Snape <severus@hogwarts.edu.uk>'
      @mail['to'] = 'albus@hogwarts.edu.uk'
      @mail['subject'] = 'The dark lord is back'
      @mail['body'] = 'He - who must not be named - is back'
    end

    it 'sets to true when passed as true' do
      @mail['preserve_recipients'] = true
      expect_any_instance_of(AmqpMailer::NotificationDispatcher).to receive(:perform).with(hash_including(preserve_recipients: true), false)
      AmqpMailer::DeliveryMethod.new.deliver!(@mail)
    end

    it 'sets to false when not passed' do
      expect_any_instance_of(AmqpMailer::NotificationDispatcher).to receive(:perform).with(hash_including(preserve_recipients: false), false)
      AmqpMailer::DeliveryMethod.new.deliver!(@mail)
    end

    it 'sets to false passed values other than true' do
      @mail['preserve_recipients'] = 'not true'
      expect_any_instance_of(AmqpMailer::NotificationDispatcher).to receive(:perform).with(hash_including(preserve_recipients: false), false)
      AmqpMailer::DeliveryMethod.new.deliver!(@mail)
    end
  end

  context 'for reply_to' do
    before do
      @mail = Mail::Message.new
      @mail['from'] = 'Professor Snape <severus@hogwarts.edu.uk>'
      @mail['to'] = 'albus@hogwarts.edu.uk'
      @mail['subject'] = 'The dark lord is back'
      @mail['body'] = 'He - who must not be named - is back'
    end

    it 'sets reply_to when passed' do
      @mail['reply_to'] = 'reply@getsimpl.com'
      expect_any_instance_of(AmqpMailer::NotificationDispatcher).to receive(:perform).with(hash_including(reply_to: 'reply@getsimpl.com'), false)
      AmqpMailer::DeliveryMethod.new.deliver!(@mail)
    end

    it 'sets nothing when not passed' do
      expect_any_instance_of(AmqpMailer::NotificationDispatcher).not_to receive(:perform).with(hash_including(reply_to: anything), false)
      AmqpMailer::DeliveryMethod.new.deliver!(@mail)
    end

    it 'sets to false passed values other than true' do
      @mail['preserve_recipients'] = 'not true'
      expect_any_instance_of(AmqpMailer::NotificationDispatcher).to receive(:perform).with(hash_including(preserve_recipients: false), false)
      AmqpMailer::DeliveryMethod.new.deliver!(@mail)
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

  context 'when service_id in missing' do
    it 'raises error' do
      AmqpMailer.configuration.service_id = nil
      mail = Mail::Message.new

      expect {AmqpMailer::DeliveryMethod.new.deliver!(mail)}.to \
      raise_error(AmqpMailer::DeliveryMethod::MissingConfiguration, 'Sender Service ID is missing')
    end
  end

  context 'when attachments is sent' do
    it 'should send the attachment in payload' do
      mail = Mail::Message.new
      mail['from'] = 'Professor Snape <severus@hogwarts.edu.uk>'
      mail['to'] = 'albus@hogwarts.edu.uk'
      mail['subject'] = 'The dark lord is back'
      mail['body'] = 'He - who must not be named - is back'
      attachments = [{bucket_id: SecureRandom.hex, object_key: SecureRandom.hex}]
      mail['attachments'] = attachments.to_json
      amqp_instance_double = instance_double(AmqpMailer::NotificationDispatcher)
      expect(AmqpMailer::NotificationDispatcher).to receive(:new).and_return(amqp_instance_double)
      expect(amqp_instance_double).to receive(:perform){|payload, use_priority_queue|
        expect(payload[:attachments]).not_to be_nil
        expect(payload[:attachments]).to eq(JSON.parse(attachments.to_json))
      }

      AmqpMailer::DeliveryMethod.new.deliver!(mail)
    end
  end
end
