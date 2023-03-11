# frozen_string_literal: true

module Errordeck
  module Scrubber
    class Cookie
      # scrub a cookie
      def initialize(cookie)
        @cookie = cookie
      end

      # scrub a cookie
      def scrub
        scrub_cookie(@cookie)
      end

      private

      def scrub_cookie(cookie)
        return nil if cookie.nil?

        cookie.each do |key, _value|
          cookie[key] = Errordeck::Scrubber::SENSITIVE_VALUE if Errordeck::Scrubber::SENSITIVE_PARAMS.include?(key)
        end
      end
    end
  end
end
