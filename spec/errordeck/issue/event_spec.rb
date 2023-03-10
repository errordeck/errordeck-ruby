# frozen_string_literal: true

RSpec.describe Errordeck::Event do
  # create a new event
  it "creates a new event" do
    # create a new event
    event = Errordeck::Event.new(
      "error",
      nil,
      nil,
      "0.0.0",
      "0.0.0",
      "development",
      "test",
      nil,
      nil,
      nil,
      nil,
      nil,
      nil,
      nil
    )
    # check the event
    expect(event).to be_a(Errordeck::Event)
    expect(event.level).to eq("error")
    expect(event.message).to eq("test")
    expect(event.release).to eq("0.0.0")
    expect(event.dist).to eq("0.0.0")
    expect(event.environment).to eq("development")
    puts event.to_json
  end
end
