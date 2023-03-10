# frozen_string_literal: true

module Errordeck
  module Scrubber
    SENSITIVE_PARAMS = %w[password password_confirmation email secret token session].freeze
    SENSITIVE_HEADERS = %w[Authorization Cookie Set-Cookie].freeze
    SENSITIVE_VALUE = "[FILTERED]"
  end
end
