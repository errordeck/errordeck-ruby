# frozen_string_literal: true

module Errordeck
  module Scrubber
    class Header
      # scrub an HTTP header
      def initialize(header)
        @header = header
      end

      # scrub an HTTP header
      def scrub
        scrub_header(@header)
      end

      private

      def scrub_header(header)
        return nil if header.nil?

        header.to_h do |key, value|
          if Errordeck::Scrubber::SENSITIVE_HEADERS.include?(key)
            [key, Errordeck::Scrubber::SENSITIVE_VALUE]
          else
            [key, value]
          end
        end
      end
    end
  end
end
