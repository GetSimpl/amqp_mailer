require 'mail'
require 'securerandom'
require 'amqp_mailer/utils'

module AmqpMailer
  class DeliveryMethod
    DEFAULT_SIMPL_USER_ID = nil
    DEFAULT_SIMPL_PHONE_NUMBER = '0000000000'

    include AmqpMailer::Utils

    class MissingConfiguration < StandardError; end

    attr_reader :settings

    def initialize(*)
      @settings = {}
      raise MissingConfiguration, 'AMQP URL is missing' if blank?(AmqpMailer.configuration.amqp_url)
      raise MissingConfiguration, 'Notifications topic exchange is missing' if blank?(AmqpMailer.configuration.notifications_topic_exchange)
      raise MissingConfiguration, 'Sender Service ID is missing' if blank?(AmqpMailer.configuration.service_id)
    end

    def deliver!(mail)
      NotificationDispatcher.new.perform(payload(mail), !!mail['use_priority_queue'])
    end

    private

    # rubocop:disable Metrics/MethodLength
    def payload(mail)
      to_addresses_valid = mail['to'].field.errors.empty?
      puts "To addresses are invalid #{mail['to']} | #{mail['X-SIMPL-USER-ID'].value} | #{mail.subject} " unless to_addresses_valid
      payload = {
          content: mail.body.raw_source,
          subject: mail.subject,
          from_name: mail['from'].address_list.addresses.first.name,
          from_email: mail['from'].address_list.addresses.first.address,
          to: to_addresses_valid ? mail['to'].address_list.addresses.collect{|a| {email: a.address, name: a.name}} : [],
          preserve_recipients: mail['preserve_recipients']  ? mail['preserve_recipients'].value.to_s.downcase == 'true' : false,
          user_id: blank?(mail['X-SIMPL-USER-ID']) ? DEFAULT_SIMPL_USER_ID : mail['X-SIMPL-USER-ID'].value,
          phone_number: blank?(mail['X-SIMPL-PHONE-NUMBER']) ? DEFAULT_SIMPL_PHONE_NUMBER : mail['X-SIMPL-PHONE-NUMBER'].value,
          service_id: AmqpMailer.configuration.service_id,
          notification_type: 'email',
          notification_id: SecureRandom.uuid
      }
      payload.merge!(reply_to: mail['reply_to'].value) if mail['reply_to']
      payload.merge!(attachments: JSON.parse(mail['attachments'].value)) if mail['attachments']
      payload
    end
    # rubocop:enable Metrics/MethodLength
  end
end
