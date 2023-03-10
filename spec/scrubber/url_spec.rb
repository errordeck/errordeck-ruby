# frozen_string_literal: true

RSpec.describe Errordeck::Scrubber::Url do
  # scrub a url
  it "scrubs a url" do
    # scrub a url
    scrubbed = Errordeck::Scrubber::Url.new("https://www.example.com?password=1234&token=1234&secret=1234").scrub
    # check the scrubbed url
    expect(scrubbed).to eq("https://www.example.com?password=[FILTERED]&token=[FILTERED]&secret=[FILTERED]")
  end

  # scrub a url with a custom filter
  it "scrubs a url with a custom filter" do
    # scrub a url with a custom filter
    scrubbed = Errordeck::Scrubber::Url.new("https://www.example.com?password=1234&token=1234&secret=1234",
                                            %w[password token]).scrub

    # check the scrubbed url
    expect(scrubbed).to eq("https://www.example.com?password=[FILTERED]&token=[FILTERED]&secret=1234")
  end
end
