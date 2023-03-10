# frozen_string_literal: true

RSpec.describe Errordeck do
  it "has a version number" do
    expect(Errordeck::VERSION).not_to be nil
  end

  it "configures the gem" do
    Errordeck.configure do |config|
      config[:level] = "error"
      config[:release] = "0.0.0"
      config[:dist] = "0.0.0"
      config[:environment] = "development"
    end

    expect(Errordeck.config).to eq({
                                     level: "error",
                                     release: "0.0.0",
                                     project_id: nil,
                                     dist: "0.0.0",
                                     server_name: nil,
                                     environment: "development",
                                     token: nil
                                   })
  end
end
