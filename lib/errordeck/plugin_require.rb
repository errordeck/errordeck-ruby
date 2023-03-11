# frozen_string_literal: true

# check if rack is defined and require middleware
if defined?(Rack)
  require_relative "middleware/rack"
  if defined?(Rack::Builder)
    # Rack 2.0
    Rack::Builder.include Errordeck::Middleware::Rack
  end
end
# check if rails is defined and require middleware
if defined?(Rails) && Gem::Version.new(Rails::VERSION::STRING) >= Gem::Version.new("3.2") && defined?(Rails::Railtie)
  require_relative "middleware/rails"
end
