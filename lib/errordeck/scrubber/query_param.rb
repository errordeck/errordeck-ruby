# frozen_string_literal: true

module Errordeck
  module Scrubber
    class QueryParam
      # scrub a query parameter
      def initialize(query, filter = nil)
        @query = query
        @filter = filter || Errordeck::Scrubber::SENSITIVE_PARAMS
      end

      # scrub a query parameter
      def scrub
        scrub_query(@query)
      end

      private

      def scrub_query(query)
        return nil if query.nil?

        query.split("&").map do |param|
          key, value = param.split("=")
          if @filter.include?(key)
            "#{key}=#{Errordeck::Scrubber::SENSITIVE_VALUE}"
          else
            param
          end
        end.join("&")
      end
    end
  end
end
