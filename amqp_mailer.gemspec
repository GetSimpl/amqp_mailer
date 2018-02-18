
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "amqp_mailer/version"

Gem::Specification.new do |spec|
  spec.name          = "amqp_mailer"
  spec.version       = AmqpMailer::VERSION
  spec.authors       = ["Simpl"]
  spec.email         = ["dev@getsimpl.com"]

  spec.summary       = "Adds a new action mailer delivery method - amqp"
  spec.description   = "This gem adds a new delivery method amqp.
                          This allows for sending email content to another service using amqp message.
                          And that service is responsible for hanfling email delivery"
  spec.homepage      = "https://github.com/GetSimpl/amqp_mailer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.7"
end
