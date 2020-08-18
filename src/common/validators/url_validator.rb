require 'uri'

module Common
  module Validators
    class UrlValidator

      def initialize(error_message = nil)
        @error_message = error_message || "Url Validation Error:"
      end

      def execute(url)
        valid = false

        begin
          uri = URI.parse(url)
          valid = uri.kind_of?(URI::HTTP)
          unless valid
            return @error_message
          end
        rescue URI::InvalidURIError => e
          return "#{@error_message} #{e.message}"
        end

        return nil
      end
    end
  end
end