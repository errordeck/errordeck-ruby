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

        # split on = and ; to get key value pairs
        cookie.split(";").map do |param|
          key, value = param.split("=")
          if Errordeck::Scrubber::SENSITIVE_PARAMS.include?(key)
            "#{key}=#{Errordeck::Scrubber::SENSITIVE_VALUE}"
          else
            param
          end
        end.join(";")
      end
    end
  end
end
