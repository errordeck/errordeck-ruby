# frozen_string_literal: true

module Errordeck
  class Request
    attr_accessor :url, :method, :data, :query_string, :cookies, :headers, :env

    def initialize(url, method, data, query_string, cookies, headers, env)
      @url = Scrubber::Url.new(url).scrub
      @method = method
      @data = data
      @query_string = Scrubber::QueryParam.new(query_string).scrub
      @cookies = Scrubber::Cookie.new(cookies).scrub
      @headers = Scrubber::Header.new(headers).scrub
      @env = env
    end

    # Parse a request from a rack env
    def self.parse_from_rack_env(env)
      url = env["REQUEST_URI"]
      method = env["REQUEST_METHOD"]
      data = env["rack.input"].read
      query_string = env["QUERY_STRING"]
      cookies = split_to_has_on(env["HTTP_COOKIE"], ";")
      headers = env.select do |k, _v|
                  k.start_with?("HTTP_")
                end.transform_keys { |k| k.sub(/^HTTP_/, "").gsub("_", "-").capitalize }
      env = env

      new(url, method, data, query_string, cookies, headers, env)
    end

    def self.split_to_has_on(resource, split = ";")
      resource.split(split).to_h do |item|
        item.split("=").map(&:strip)
      end
    end

    def as_json(*_options)
      {
        url: @url,
        method: @method,
        # data: @data,
        query_string: @query_string,
        cookies: @cookies,
        headers: @headers
      }
    end

    def to_json(*options)
      JSON.generate(as_json, *options)
    end
  end
end
