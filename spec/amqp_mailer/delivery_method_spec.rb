# require 'spec_helper'
#
# describe AmqpMailer::DeliveryMethod do
#   it 'raises an exception if no amqp_url passed' do
#     expect { AmqpMailer::DeliveryMethod.new }.to raise_exception(AmqpMailer::DeliveryMethod::MissingConfiguration)
#     expect { AmqpMailer::DeliveryMethod.new(amqp_url: 'amqp://boggart') }.to_not raise_exception
#   end
# end