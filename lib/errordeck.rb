# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

require_relative "errordeck/version"
require_relative "errordeck/configuration"
Dir["#{File.dirname(__FILE__)}/errordeck/errordeck/**/*.rb"].sort.each { |file| require file }
require_relative "errordeck/request_handler"
require_relative "errordeck/wrapper"
require_relative "errordeck/scrubber/scrubber"
require_relative "errordeck/plugin_require"

module Errordeck
  class Error < StandardError; end

  class << self
    def info(message:, extra: nil)
      generate_event(level: "info", message: message, extra: extra)
    end

    def warning(message:, extra: nil)
      generate_event(level: "warning", message: message, extra: extra)
    end

    def error(message:, extra: nil)
      generate_event(level: "error", message: message, extra: extra)
    end

    def fatal(message:, extra: nil)
      generate_event(level: "fatal", message: message, extra: extra)
    end

    def generate_event(level:, message:, extra: nil, capture: true)
      wrap(capture) do |b|
        b.message(level, message, extra)
      end
    end

    def message(level:, message:, extra: nil, capture: true)
      wrap(capture) do |b|
        b.message(level, message, extra)
      end
    end

    def capture(exception:, user: nil, tags: nil, capture: true)
      wrap(capture) do |b|
        b.user_context = user if user
        b.tags_context = tags if tags
        b.capture(exception)
      end
    end

    def wrap(capture = true)
      wrapper = Wrapper.new
      begin
        yield(wrapper)
        wrapper.send_event if capture
      rescue Exception => e
        wrapper.capture(e)
        wrapper.send_event if capture
        raise e
      end
    end
  end
end
