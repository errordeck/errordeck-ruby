# frozen_string_literal: true

module Errordeck
  class Request
    attr_accessor :url, :method, :data, :query_string, :cookies, :headers, :env

    HEADERS = %w[HOST USER-AGENT ACCEPT ACCEPT_LANGUAGE ACCEPT_ENCODING CONNECTION CACHE_CONTROL
                 UPGRADE_INSECURE_REQUESTS DNT SEC_FETCH_SITE SEC_FETCH_MODE SEC_FETCH_USER SEC_FETCH_DEST REFERER].freeze
    COOKIE = %w[COOKIE].freeze

    def initialize(url, method, data, query_string, cookies, headers, env)
      @url = Scrubber::Url.new(url).scrub
      @method = method
      @data = data
      @query_string = Scrubber::QueryParam.new(query_string).scrub
      @cookies = Scrubber::Cookie.new(cookies).scrub
      @headers = Scrubber::Header.new(headers.transform_keys { |k| k.to_s.gsub("HTTP_", "").gsub("_", "-") }).scrub
      @env = env
    end

    def self.parse_from_rack_env(env)
      request = RequestHandler.parse_from_rack_env(env)
      new(request.url, request.method, nil, request.query_string, request.cookies, request.headers, env)
    end

    def self.parse_from_request_handler(request)
      new(request.url, request.method, nil, request.query_string, request.cookies, request.headers, nil)
    end

    def self.split_to_has_on(resource, split = ";")
      resource.split(split).each_with_object({}) do |item, hash|
        key, value = item.split("=").map(&:strip)
        hash[key] = value
      end
    end

    def headers
      filtered_headers
    end

    def as_json(*_options)
      {
        url: @url,
        method: @method,
        query_string: @query_string,
        headers: headers
      }
    end

    def to_json(*options)
      JSON.generate(as_json, *options)
    end

    private

    def filtered_headers
      @headers.select { |k, _v| HEADERS.include?(k) }
    end
  end
end
