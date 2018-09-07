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
      {
          content: mail.body.raw_source,
          subject: mail.subject,
          from_name: mail['from'].address_list.addresses.first.name,
          from_email: mail['from'].address_list.addresses.first.address,
          to_email: mail.to.first,
          user_id: blank?(mail['X-SIMPL-USER-ID']) ? DEFAULT_SIMPL_USER_ID : mail['X-SIMPL-USER-ID'].value,
          phone_number: blank?(mail['X-SIMPL-PHONE-NUMBER']) ? DEFAULT_SIMPL_PHONE_NUMBER : mail['X-SIMPL-PHONE-NUMBER'].value,
          service_id: AmqpMailer.configuration.service_id,
          notification_type: 'email',
          notification_id: SecureRandom.uuid
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
