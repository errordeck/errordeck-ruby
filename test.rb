# frozen_string_literal: true

require "./lib/errordeck/errordeck"

Errordeck.configure do |config|
  config[:token] = "_r-3A7egL7uMHgAkdRodzxxxAQo"
  config[:project_id] = "1"
  config[:environment] = "development"
  config[:release] = "0.0.0"
  config[:dist] = "0.0.0"
end

# send a message to errordeck
Errordeck.message("test")

begin
  raise "test"
rescue StandardError => e
  Errordeck.capture(e)
end
