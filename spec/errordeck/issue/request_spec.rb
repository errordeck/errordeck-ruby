# frozen_string_literal: true

RSpec.describe Errordeck::Request do
  let(:env) do
    {
      "REQUEST_URI" => "https://example.com/path?foo=bar",
      "REQUEST_METHOD" => "GET",
      "rack.input" => StringIO.new("request body"),
      "QUERY_STRING" => "foo=bar",
      "HTTP_COOKIE" => "session=value",
      "HTTP_USER_AGENT" => "Mozilla/5.0"
    }
  end

  describe ".parse_from_rack_env" do
    subject { described_class.parse_from_rack_env(env) }

    it "returns a parsed request object" do
      expect(subject.url).to eq("https://example.com/path?foo=bar")
      expect(subject.method).to eq("GET")
      expect(subject.query_string).to eq("foo=bar")
      expect(subject.cookies).to eq("session" => "[FILTERED]")
      expect(subject.headers).to eq("USER-AGENT" => "Mozilla/5.0")
    end
  end

  describe "#as_json" do
    subject { described_class.new("https://example.com/path", "POST", "request body", "foo=bar", { "cookie" => "value" }, { "USER_AGENT" => "Mozilla/5.0" }, env).as_json }

    it "returns a JSON representation of the request" do
      expect(subject).to eq(
        url: "https://example.com/path",
        method: "POST",
        query_string: "foo=bar",
        headers: { "USER-AGENT" => "Mozilla/5.0" }
      )
    end
  end

  describe "#to_json" do
    subject { described_class.new("https://example.com/path", "POST", "request body", "foo=bar", { "cookie" => "value" }, { "USER_AGENT" => "Mozilla/5.0" }, env).to_json }

    it "returns a JSON representation of the request" do
      expect(subject).to eq('{"url":"https://example.com/path","method":"POST","query_string":"foo=bar","headers":{"USER-AGENT":"Mozilla/5.0"}}')
    end
  end
end
