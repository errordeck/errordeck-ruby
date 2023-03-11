# frozen_string_literal: true

# rack middleware to capture request context and exception to send to errordeck
# Compare this snippet from lib/errordeck/middleware/rack.rb:

module Errordeck
  module Middleware
    class Rack
      def initialize(app)
        @app = app
      end

      def call(env)
        Errordeck.wrap do |b|
          b.set_request(env)
          b.set_transaction(env["PATH_INFO"])

          begin
            @app.call(env)
          rescue Exception => e
            b.capture(e)
            raise e
          end
        end
      end
    end
  end
end
