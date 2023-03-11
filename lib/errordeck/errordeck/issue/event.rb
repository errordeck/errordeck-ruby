# frozen_string_literal: true

require "securerandom"
module Errordeck
  class Event
    SDK = { "name" => "errordeck-ruby", "version" => Errordeck::VERSION }.freeze

    attr_accessor :id, :timestamp, :platform, :level, :logger, :tags, :transaction, :server_name, :release, :dist,
                  :environment, :message, :modules, :extra, :exceptions, :contexts, :request, :sdk, :user

    def initialize(level:, transaction:, message:, server_name: nil, release: nil, dist: nil,
                   environment: "development", modules: nil, extra: nil, tags: nil, exceptions: nil, contexts: nil, request: nil, user: nil)
      @id = ::SecureRandom.uuid.delete("-")
      @timestamp = Time.now.utc
      @platform = :ruby
      @level = level
      @logger = :ruby
      @transaction = transaction
      @server_name = server_name
      @release = release
      @dist = dist
      @environment = environment
      @message = message
      @modules = modules
      @extra = extra
      @exceptions = exceptions
      @contexts = contexts
      @request = request
      @tags = tags
      @sdk = SDK
      @user = user
    end

    def to_json(*_args)
      {
        event_id: @id,
        timestamp: @timestamp.to_i,
        platform: @platform,
        level: @level,
        logger: @logger,
        transaction: @transaction,
        server_name: @server_name,
        release: @release,
        dist: @dist,
        environment: @environment,
        message: @message,
        modules: @modules,
        extra: @extra,
        exceptions: @exceptions,
        contexts: @contexts,
        request: @request,
        sdk: @sdk,
        user: @user
      }.to_json
    end
  end
end
