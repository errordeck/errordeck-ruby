# frozen_string_literal: true

RSpec.describe Errordeck::Middleware::Rack do
  # create a new rack middleware
  it "creates a new rack middleware" do
    # create a new rack middleware
    middleware = Errordeck::Middleware::Rack.new(nil)
    # check the middleware
    expect(middleware).to be_a(Errordeck::Middleware::Rack)
  end
end
