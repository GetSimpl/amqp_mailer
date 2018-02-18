require 'mail'
require 'securerandom'

module AmqpMailer
  class DeliveryMethod
    DEFAULT_SIMPL_PHONE_NUMBER = '0000000000'

    class MissingConfiguration < StandardError; end

    def initialize(*)
      raise MissingConfiguration, 'AMQP URL is missing' if AmqpMailer.configuration.amqp_url.blank?
      raise MissingConfiguration, 'Notifications topic exchange is missing' if AmqpMailer.configuration.notifications_topic_exchange.blank?
    end

    def deliver!(mail)
      NotificationDispatcher.new.perform(payload(mail))
    end

    private

    def payload(mail)
      {
          content: mail.body.raw_source,
          subject: mail.subject,
          from_name: mail['from'].address_list.addresses.first.name,
          from_email: mail['from'].address_list.addresses.first.address,
          to_email: mail.to.first,
          phone_number: mail['X-SIMPL-PHONE-NUMBER'].present? ? mail['X-SIMPL-PHONE-NUMBER'].value : DEFAULT_SIMPL_PHONE_NUMBER,
          service_id: 'verification-service',
          notification_type: 'email',
          notification_id: SecureRandom.uuid
      }
    end
  end
end
