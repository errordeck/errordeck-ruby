# frozen_string_literal: true

require "spec_helper"
require "errordeck/request_handler"

RSpec.describe Errordeck::RequestHandler do
  let(:env) do
    {
      "REQUEST_METHOD" => "GET",
      "HTTP_HOST" => "example.com",
      "REQUEST_URI" => "/users?id=1",
      "rack.url_scheme" => "https"
    }
  end

  describe ".set_request_from_env" do
    context "when Rack::Request and Sinatra::Request are not defined" do
      it "returns a hash with request information" do
        allow(Object).to receive(:defined?).with(:Sinatra).and_return(false)
        allow(Object).to receive(:defined?).with(:Rack).and_return(false)
        request = Errordeck::RequestHandler.set_request_from_env(env)
        expect(request).to be_a(Hash)
        expect(request[:method]).to eq("GET")
        expect(request[:url]).to eq("https://example.com/users?id=1")
        expect(request[:query_string]).to eq("id=1")
        expect(request[:params]).to eq({ "id" => "1" })
        expect(request[:cookies]).to eq({})
        expect(request[:headers]).to eq({"HTTP_HOST" => "example.com" })
      end
    end
  end

  describe ".parse_from_rack_env" do
    it "returns a new instance of RequestHandler" do
      allow(Errordeck::RequestHandler).to receive(:set_request_from_env).and_return({})
      request_handler = Errordeck::RequestHandler.parse_from_rack_env(env)
      expect(request_handler).to be_a(Errordeck::RequestHandler)
    end
  end

  describe "#method" do
    it "returns the request method" do
      request_handler = Errordeck::RequestHandler.parse_from_rack_env({ REQUEST_METHOD: "GET" })
      expect(request_handler.method).to eq("GET")
    end
  end

  describe "#url" do
    it "returns the request URL" do
      request_handler = Errordeck::RequestHandler.parse_from_rack_env({ REQUEST_URI: "https://example.com/users?id=1" })
      expect(request_handler.url).to eq("https://example.com/users?id=1")
    end
  end

  describe "#params" do
    it "returns the request parameters" do
      request_handler = Errordeck::RequestHandler.parse_from_rack_env({ params: { "id" => "1" } })
      expect(request_handler.params).to eq({ "id" => "1" })
    end
  end

  describe "#controller" do
    it "returns the controller parameter" do
      request_handler = Errordeck::RequestHandler.parse_from_rack_env({ params: { "controller" => "users" } })
      expect(request_handler.controller).to eq("users")
    end
  end

  describe "#action" do
    it "returns the action parameter" do
      request_handler = Errordeck::RequestHandler.parse_from_rack_env({ params: { "action" => "show" } })
      expect(request_handler.action).to eq("show")
    end
  end

  describe "#query_string" do
    it "returns the query string" do
      request_handler = Errordeck::RequestHandler.parse_from_rack_env({ query_string: "id=1" })
      expect(request_handler.query_string).to eq("id=1")
    end
  end

  describe "#cookies" do
    it "returns the request cookies" do
      request_handler = Errordeck::RequestHandler.parse_from_rack_env({ cookies: { "session_id" => "12345" } })
      expect(request_handler.cookies).to eq({ "session_id" => "12345" })
    end
  end

  describe "#headers" do
    it "returns the request headers" do
      request_handler = Errordeck::RequestHandler.parse_from_rack_env({ headers: { "HTTP_HOST" => "example.com" } })
      expect(request_handler.headers).to eq({ "HTTP_HOST" => "example.com" })
    end
  end

  describe "#to_hash" do
    it "returns a hash representation of the request" do
      request_handler = Errordeck::RequestHandler.parse_from_rack_env({
                                                        method: "GET",
                                                        url: "https://example.com/users?id=1",
                                                        query_string: "id=1",
                                                        cookies: { "session_id" => "12345" },
                                                        headers: { "HTTP_HOST" => "example.com" },
                                                        params: { "controller" => "users", "action" => "show" }
                                                      })
      expect(request_handler.to_hash).to eq({
                                              method: "GET",
                                              url: "https://example.com/users?id=1",
                                              query_string: "id=1",
                                              cookies: { "session_id" => "12345" },
                                              headers: { "HTTP_HOST" => "example.com" },
                                              params: { "controller" => "users", "action" => "show" }
                                            })
    end
  end
end
