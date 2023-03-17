# frozen_string_literal: true

module Errordeck
  module Middleware
    module Rails
      class ErrordeckMiddleware
        def initialize(app)
          @app = app
        end

        def call(env)
          dup.call!(env)
        end

        def call!(env)
          response = @app.call(env)
        rescue Exception => e
          notify_exception(env, e)
          raise e
        else
          exception = collect_exception(env)
          notify_exception(env, exception) if exception
          response
        end

        private

        def notify_exception(env, exception)
          return unless exception

          Errordeck.wrap do |b|
            b.set_action_context(env)
            b.capture(exception)
          end
        end

        def collect_exception(env)
          return nil unless env

          env["action_dispatch.exception"] || env["sinatra.error"] || env["rack.exception"]
        end
      end
    end
  end

  class Railtie < Rails::Railtie
    initializer "errordeck.middleware.rails" do |app|
      app.config.middleware.insert 0, Errordeck::Middleware::Rails::ErrordeckMiddleware
    end
  end
end
