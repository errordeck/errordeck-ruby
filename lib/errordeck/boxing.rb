# frozen_string_literal: true

module Errordeck
  # the class that setup the events for Errordeck
  class Boxing
    # initialize the boxing class

    attr_accessor :error_event, :transaction, :request, :user, :tags, :modules, :context

    def initialize
      @error_event = nil
      @transaction = nil
      @request = nil
      @user = nil
      @tags = nil
      if Gem::Specification.respond_to?(:map)
        @modules = Hash[Gem::Specification.map do |spec|
                          [spec.name, spec.version.to_s]
                        end]
      end
      @context = Context.context
    end

    # send event to errordeck
    def send_event
      Errordeck.send_event(error_event)
    end

    def capture(exception, user = nil, tags = nil)
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

    def set_request(request = nil)
      @request = request
    end

    # set user context
    def user_context(user)
      @user = user
    end

    attr_writer :context

    # set tags context
    def tags_context(tags)
      @tags = tags
    end

    private

    def generate_from_exception(exception)
      # Make project_root here
      project_root = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
      exceptions = Errordeck::Exception.parse_from_exception(exception, project_root)

      Event.new(
        config[:level] || "error",
        transaction,
        server_name_env,
        config[:release],
        config[:dist],
        config[:environment],
        exception.message,
        modules,
        nil,
        nil,
        exceptions,
        context,
        nil,
        nil
      )
    end

    def generate_boxing_event(level, message, extra = nil)
      Event.new(
        level,
        transaction,
        server_name_env,
        config[:release],
        config[:dist],
        config[:environment],
        message,
        modules,
        extra,
        nil,
        nil,
        context,
        nil,
        nil
      )
    end

    def config
      Errordeck.config
    end

    def server_name_env
      # set server_name context
      config[:server_name] || ENV["SERVER_NAME"]
    end
  end
end
