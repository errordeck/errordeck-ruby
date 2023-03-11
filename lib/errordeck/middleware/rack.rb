# frozen_string_literal: true

# rack middleware to capture request context and exception to send to errordeck
# Compare this snippet from lib/errordeck/middleware/rack.rb:

module Errordeck
  module Middleware
    module Rack
      def self.new(app)
        ->(env) { call(env, app) }
      end

      def self.call(env, app)
        Errordeck.wrap do |b|
          b.set_request(env)
          b.set_transaction(env["PATH_INFO"])

          begin
            app.call(env)
          rescue Exception => e
            b.capture(e)
            raise e
          end
        end
      end
    end
  end
end
