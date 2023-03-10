# frozen_string_literal: true

RSpec.describe Errordeck::Scrubber::Header do
  # scrub an HTTP header
  it "scrubs an HTTP header" do
    # scrub an HTTP header
    scrubbed = Errordeck::Scrubber::Header.new("Authorization" => "1234", "Cookie" => "1234",
                                               "Set-Cookie" => "1234").scrub
    # check the scrubbed HTTP header
    expect(scrubbed).to eq("Authorization" => "[FILTERED]", "Cookie" => "[FILTERED]", "Set-Cookie" => "[FILTERED]")
  end
end
