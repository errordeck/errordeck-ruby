# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

require_relative 'errordeck/version'
require_relative 'boxing'
require_relative 'scrubber/scrubber'
Dir["#{File.dirname(__FILE__)}/errordeck/**/*.rb"].sort.each { |file| require file }

module Errordeck
  class Error < StandardError; end

  DEFAULT_CONFIG = {
    token: nil,
    project_id: nil,
    environment: "development",
    server_name: nil,
    release: "0.0.0",
    dist: "0.0.0",
    level: "error"
  }.freeze

  @config = DEFAULT_CONFIG.dup

  class << self
    attr_accessor :config

    def configure(**options)
      @config.merge!(options)
    end

    def send_issue(project_id:, token:, event:)
      uri = URI.parse("https://app.errordeck.com/api/#{project_id}/store")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, 'Authorization' => "Bearer #{token}")
      request['Content-Type'] = 'application/json'
      event_json = event.to_json
      response = http.request(request, event_json)
      response.body
    rescue StandardError => e
      raise Error, "Error sending issue to Errordeck: #{e.message}"
    end

    def info(message:, extra: nil)
      generate_event(level: 'info', message: message, extra: extra)
    end

    def warning(message:, extra: nil)
      generate_event(level: 'warning', message: message, extra: extra)
    end

    def error(message:, extra: nil)
      generate_event(level: 'error', message: message, extra: extra)
    end

    def fatal(message:, extra: nil)
      generate_event(level: 'fatal', message: message, extra: extra)
    end

    def generate_event(level:, message:, extra: nil, capture: true)
      boxing(capture) do |b|
        b.message(level, message, extra)
      end
    end

    def message(level:, message:, extra: nil, capture: true)
      boxing(capture) do |b|
        b.message(level, message, extra)
      end
    end

    def capture(exception:, user: nil, tags: nil, capture: true)
      boxing(capture) do |b|
        b.user_context = user if user
        b.tags_context = tags if tags
        b.capture(exception)
      end
    end

    private

    def boxing(capture = true)
      boxing = Boxing.new
      yield boxing
      if capture
        event = boxing.send_event
        send_issue(project_id: config[:project_id], token: config[:token], event: event)
      else
        boxing.error_event
      end
    end
  end
end