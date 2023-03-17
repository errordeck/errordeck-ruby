# frozen_string_literal: true

require "uri"

module Errordeck
  class RequestHandler
    attr_accessor :request

    def initialize(request)
      @request = request
    end

    def self.set_request_from_env(rack_env)
      if defined?(Sinatra)
        Sinatra::Request.new(rack_env)
      elsif defined?(Rack)
        Rack::Request.new(rack_env)
      else
        request_hash(rack_env)
      end
    end

    def self.request_hash(rack_env)
      request = {}
      rack_env = rack_env.dup.transform_keys { |k| k.to_s.upcase }

      if rack_env["REQUEST_URI"] || rack_env["URL"]
        url = URI.parse(rack_env["REQUEST_URI"] || rack_env["URL"])
        url.scheme ||= rack_env["RACK.URL_SCHEME"] || "https"
        url.host ||= rack_env["HTTP_HOST"] || "localhost"
      else
        scheme = rack_env["RACK.URL_SCHEME"] || "https"
        host = rack_env["HTTP_HOST"] || "localhost"
        path = rack_env["PATH_INFO"] || "/"
        query_string = rack_env["QUERY_STRING"] || ""
        url = URI.parse("#{scheme}://#{host}#{path}")
        url.query = query_string unless query_string.empty?
      end

      request[:url] = url.to_s
      request[:query_string] = url.query || ""
      request[:params] = rack_env["PARAMS"] || parse_query_string(request[:query_string])
      request[:method] = rack_env["REQUEST_METHOD"] || "GET"
      request[:cookies] = (rack_env["HTTP_COOKIE"] || rack_env["COOKIES"]) ? parse_query_string(rack_env["HTTP_COOKIE"] || rack_env["COOKIES"]) : {}
      request[:headers] = (rack_env["HEADERS"] || rack_env).select { |k, _| k.start_with?("HTTP_") }
      request
    end

    def self.parse_from_rack_env(rack_env)
      request = set_request_from_env(rack_env.dup)
      new(request)  
    end

    def method
      if @request.respond_to?(:request_method)
        @request.request_method
      else
        @request[:method]
      end
    end

    def url
      if @request.respond_to?(:url)
        @request.url
      else
        @request[:url]
      end
    end

    def params
      if @request.respond_to?(:params)
        (request.env["action_dispatch.request.parameters"] || request.params).to_hash || {}
      else
        @request[:params] || {}
      end
    end

    def controller
      params["controller"]
    end

    def action
      params["action"]
    end

    def query_string
      @request[:query_string] || @request.query_string
    end

    def cookies
      @request[:cookies] || @request.cookies || {}
    end

    def headers
      @request[:headers] || @request.env || {}
    end

    def to_hash
      {
        method: method,
        url: url,
        query_string: query_string,
        cookies: cookies,
        headers: headers,
        params: params
      }
    end

    def self.parse_query_string(query_string)
      return query_string if query_string.is_a?(Hash)
      
      query_string.split("&").each_with_object({}) do |pair, hash|
        key, value = pair.split("=").map { |part| CGI.unescape(part) }
        if hash.key?(key)
          hash[key] = Array(hash[key])
          hash[key] << value
        else
          hash[key] = value
        end
      end
    end
  end
end
