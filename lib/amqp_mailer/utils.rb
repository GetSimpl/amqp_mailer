module AmqpMailer
  module Utils
    def blank?(obj)
      obj = obj.respond_to?(:strip) ? obj.strip : obj
      obj.respond_to?(:empty?) ? obj.empty? : !obj
    end
  end
end
