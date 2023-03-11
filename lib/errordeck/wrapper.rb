# frozen_string_literal: true

module Errordeck
  # the class that setup the events for Errordeck
  class Wrapper
    # initialize the boxing class

    attr_accessor :context
    attr_reader :error_event, :transaction, :request, :user, :tags, :modules

    # have a check if it is a message or exception
    @message = false

    @already_sent = false

    def initialize
      @error_event = nil
      @transaction = nil
      @request = nil
      @user = nil
      @tags = nil
      if Gem::Specification.respond_to?(:map)
        @modules = Gem::Specification.to_h { |spec| [spec.name, spec.version.to_s] }
      end
      @context = Context.context
    end

    # send event to errordeck
    def send_event
      return if @error_event.nil? && @message == true

      return if @already_sent

      uri = URI.parse("https://app.errordeck.com/api/#{config.project_id}/store")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, "Authorization" => "Bearer #{config.token}")
      request["Content-Type"] = "application/json"
      event_json = @error_event&.to_json
      response = http.request(request, event_json)
      @already_sent = true
    rescue StandardError => e
      raise Error, "Error sending issue to Errordeck: #{e.message}"
    end

    def capture(exception, user = nil, tags = nil)
      @message = false
      @error_event = generate_from_exception(exception)

      # set user context
      @error_event.user = user || @user

      # set tags context
      @error_event.tags = tags || @tags

      # set request context
      @error_event.request = @request
      @error_event
    end

    # generate event with level, message and extra
    def message(level, message, extra = nil)
      @message = true
      @error_event = generate_boxing_event(level, message, extra)

      # set user context
      @error_event.user = @user

      # set tags context
      @error_event.tags = @tags

      # set request context
      @error_event.request = @request
      @error_event
    end

    def set_transaction(transaction = nil)
      @transaction = transaction
    end

    def set_request(env = nil)
      @request = Request.parse_from_rack_env(env)
    end

    # set user context
    def user_context=(user)
      @user = user
    end

    # set tags context
    def tags_context=(tags)
      @tags = tags
    end

    private

    def generate_from_exception(exception)
      exceptions = Errordeck::Exception.parse_from_exception(exception, project_root)

      Event.new(
        level: config.level || "error",
        transaction: transaction,
        server_name: server_name_env,
        release: config.release,
        dist: config.dist,
        environment: config.environment,
        message: exception.message,
        modules: modules,
        exceptions: exceptions,
        contexts: context
      )
    end

    def project_root
      if defined?(Rails)
        Rails.root.to_s
      elsif defined?(Sinatra)
        Sinatra::Application.root.to_s
      elsif defined?(Rack)
        Rack::Directory.new("").root.to_s
      elsif defined?(Bundler)
        Bundler.root.to_s
      else
        File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
      end
    end

    def generate_boxing_event(level, message, extra = nil)
      Event.new(
        level: level,
        transaction: transaction,
        server_name: server_name_env,
        release: config.release,
        dist: config.dist,
        environment: config.environment,
        message: message,
        modules: modules,
        extra: extra,
        contexts: context
      )
    end

    def config
      Errordeck.configuration
    end

    def server_name_env
      # set server_name context
      config.server_name || ENV.fetch("SERVER_NAME", nil)
    end
  end
end
