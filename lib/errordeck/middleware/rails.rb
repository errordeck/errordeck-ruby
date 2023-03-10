# frozen_string_literal: true

require "active_support/concern"
module Errordeck
  # Errordeck::Middleware::Rails
  # Rails Exception Handler
  module Middleware
    module Rails
      extend ActiveSupport::Concern

      included do
        rescue_from Exception, with: :handle_exception
      end

      def handle_exception(exception)
        Errordeck.boxing do |b|
          b.set_request(request.env)
          b.set_transaction(request.env["PATH_INFO"])
          b.capture(exception)
        end

        raise exception
      end
    end
  end

  class Railtie < ::Rails::Railtie
    initializer "errordeck.configure_controller" do
      ActiveSupport.on_load(:action_controller) do
        include Errordeck::Middleware::Rails
      end
    end
  end
end
