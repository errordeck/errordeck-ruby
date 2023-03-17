# frozen_string_literal: true

module Errordeck
  class Wrapper
    attr_accessor :context
    attr_reader :error_event, :transaction, :request, :user, :tags, :modules

    def initialize
      @error_event = nil
      @transaction = nil
      @request = nil
      @user = nil
      @tags = nil
      @message = false
      @already_sent = false
      if Gem::Specification.respond_to?(:map)
        @modules = Gem::Specification.to_h do |spec|
          [spec.name, spec.version.to_s]
        end
      end
      @context = Context.context
    end

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
      @error_event.user = user || @user
      @error_event.tags = tags || @tags
      @error_event.request = @request
      @error_event
    end

    def message(level, message, extra = nil)
      @message = true
      @error_event = generate_boxing_event(level, message, extra)
      @error_event.user = @user
      @error_event.tags = @tags
      @error_event.request = @request
      @error_event
    end

    def set_action_context(env)
      request_handler = RequestHandler.parse_from_rack_env(env)
      @request = Request.parse_from_request_handler(request_handler)
    end

    def set_transaction(transaction = nil)
      @transaction = transaction
    end

    def set_request(env = nil)
      @request = Request.parse_from_rack_env(env)
    end

    def user_context=(user)
      @user = user
    end

    def tags_context=(tags)
      @tags = tags
    end

    private

    def generate_from_exception(exception)
      exceptions = Errordeck::Exception.parse_from_exception(exception, project_root)
      Event.new(
        level: config.level || exception_severity(exception),
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
      return Rails.root.to_s if defined?(Rails)
      return Sinatra::Application.root.to_s if defined?(Sinatra)
      return Rack::Directory.new("").root.to_s if defined?(Rack)
      return Bundler.root.to_s if defined?(Bundler)

      File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
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

    def exception_severity(exception)
      case exception.class.to_s
      when "SystemExit", "SignalException", "Interrupt", "NoMemoryError", "SecurityError"
        :critical
      when "RuntimeError", "TypeError", "LoadError", "NameError", "ArgumentError", "IndexError", "KeyError", "RangeError",
           "NoMethodError", "FrozenError", "SocketError", "EncodingError", "Encoding::InvalidByteSequenceError",
           "Encoding::UndefinedConversionError", "ZeroDivisionError", "SystemCallError", "Errno::EACCES",
           "Errno::EADDRINUSE", "Errno::ECONNREFUSED", "Errno::ECONNRESET", "Errno::EEXIST", "Errno::EHOSTUNREACH",
           "Errno::EINTR", "Errno::EINVAL", "Errno::EISDIR", "Errno::ENETDOWN", "Errno::ENETUNREACH", "Errno::ENOENT",
           "Errno::ENOMEM", "Errno::ENOSPC", "Errno::ENOTCONN", "Errno::ENOTDIR", "Errno::EPIPE", "Errno::ERANGE",
           "Errno::ETIMEDOUT", "Errno::ENOTEMPTY"
        :error
      when "Warning", "SecurityWarning", "DeprecatedError", "DeprecationWarning", "RuntimeWarning", "SyntaxError",
           "NameError::UndefinedVariable", "LoadError::MissingFile", "NoMethodError::MissingMethod",
           "ArgumentError::InvalidValue", "ArgumentError::MissingRequiredParameter", "IndexError::OutOfRange",
           "ActiveRecord::RecordNotFound", "Mongoid::Errors::DocumentNotFound", "Redis::CommandError", "Net::ReadTimeout",
           "Faraday::TimeoutError"
        :warning
      else
        :error
      end
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
