require 'amqp_mailer/utils'

describe AmqpMailer::Utils do
  describe 'blank?' do
    include AmqpMailer::Utils

    it 'works with strings' do
      expect(blank?('')).to eq(true)
      expect(blank?('    ')).to eq(true)
      expect(blank?('  _  ')).to eq(false)
    end

    it 'works with booleans' do
      expect(blank?(true)).to eq(false)
      expect(blank?(false)).to eq(true)
    end

    it 'works with nil' do
      expect(blank?(nil)).to eq(true)
    end
  end
end
