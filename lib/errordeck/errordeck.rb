# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

require_relative "errordeck/version"

require_relative "boxing"

require_relative "scrubber/scrubber"

# require all files from lib/errordeck/errordeck
Dir["#{File.dirname(__FILE__)}/errordeck/**/*.rb"].sort.each { |file| require file }

require_relative "plugin_require"

module Errordeck
  class Error < StandardError; end

  # set config
  @@config = {
    token: nil,
    project_id: nil,
    environment: nil,
    server_name: nil,
    release: nil,
    dist: nil
  }

  # get config
  def self.config
    @@config
  end

  # merge config with default config
  def self.configure
    yield @@config.merge!(@@config)
  end

  # send issue to errordeck
  def self.send_issue(event)
    uri = URI.parse("https://app.errordeck.com/api/#{config[:project_id]}/store")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, "Authorization" => "Bearer #{config[:token]}")
    request["Content-Type"] = "application/json"
    event_json = event.to_json
    request.body = event_json
    http.request(request)
  end

  # send info event
  def self.info(message, extra = nil)
    generate_event("info", message, extra)
  end

  # send warning event
  def self.warning(message, extra = nil)
    generate_event("warning", message, extra)
  end

  # send error event
  def self.error(message, extra = nil)
    generate_event("error", message, extra)
  end

  # send fatal event
  def self.fatal(message, extra = nil)
    generate_event("fatal", message, extra)
  end

  # generate event and send to errordeck with Boxing
  def self.generate_event(level, message, extra = nil)
    boxing do |b|
      b.message(level, message, extra)
    end
  end

  # generate event with level, message and extra
  def self.message(level, message, extra = nil, capture = true)
    boxing(capture) do |b|
      b.message(level, message, extra)
    end
  end

  # create an issue from an exception
  def self.capture(exception, user = nil, tags = nil, capture = true)
    boxing(capture) do |b|
      b.user_context(user) if user
      b.tags_context(tags) if tags
      b.capture(exception)
    end
  end

  def self.boxing(capture = true)
    boxing = Boxing.new
    yield boxing
    boxing.send_event if capture
    boxing.error_event
  end
end
