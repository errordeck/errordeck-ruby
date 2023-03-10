# frozen_string_literal: true

module Errordeck
  module Scrubber
    class Url
      def initialize(url, filter = nil)
        @url = url
        @filter = filter || Errordeck::Scrubber::SENSITIVE_PARAMS
      end

      # remove sensitive data from url
      def scrub
        uri = URI.parse(@url)
        uri.query = Errordeck::Scrubber::QueryParam.new(uri.query, @filter).scrub
        uri.to_s
      end
    end
  end
end
