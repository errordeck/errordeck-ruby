# frozen_string_literal: true

RSpec.describe Errordeck::Scrubber::QueryParam do
  # scrub a query param
  it "scrubs a query param" do
    # scrub a query param
    scrubbed = Errordeck::Scrubber::QueryParam.new("password=1234&token=1234&secret=1234").scrub
    # check the scrubbed query param
    expect(scrubbed).to eq("password=[FILTERED]&token=[FILTERED]&secret=[FILTERED]")
  end

  # scrub a query param with a custom filter
  it "scrubs a query param with a custom filter" do
    # scrub a query param with a custom filter
    scrubbed = Errordeck::Scrubber::QueryParam.new("password=1234&token=1234&secret=1234", %w[password token]).scrub

    # check the scrubbed query param
    expect(scrubbed).to eq("password=[FILTERED]&token=[FILTERED]&secret=1234")
  end
end
