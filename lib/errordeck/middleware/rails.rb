# frozen_string_literal: true

module Errordeck
  # Errordeck::Middleware::Rails
  # Rails Exception Handler
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
          begin
            response = @app.call(env)
          rescue Exception => e
            notify_exception(env, e)
            raise e
          end

          exception = collect_exception(env)
          notify_exception(env, exception) if exception

          response
        end

        private

        def notify_exception(env, exception)
          return unless exception

          Errordeck.wrap do |b|
            b.set_request(env)
            b.set_transaction(env["PATH_INFO"])
            b.capture(exception)
          end
        end

        def collect_exception(env)
          return nil unless env

          env['action_dispatch.exception'] || env['sinatra.error'] || env['rack.exception']
        end
      end
    end
  end

  class Railtie < Rails::Railtie
    initializer "errordeck.middleware.rails" do |app|
      # need to catch exceptions
      #app.config.middleware.insert_after ActionDispatch::DebugExceptions,
      #                                   Errordeck::Middleware::Rails::ErrordeckMiddleware
      app.config.middleware.insert 0, Errordeck::Middleware::Rails::ErrordeckMiddleware)
    end
  end
end
