require 'json'

require_relative "url_validator"

module Common
  module Validators
    class UrlListValidator
      
      def initialize(
        key,
        error_message = nil,
        url_validator = UrlValidator.new())

        @key = key
        @error_message = error_message || "Bad URL"
        @url_validator = url_validator
      end

      def execute(items)
        invalid = []

        (items || []).each do |item|          
          if item[@key]
            value = item[@key]
            if value.nil? || value.empty?
              invalid.push(JSON.generate(item))
            else
              error = @url_validator.execute(value)
              unless error.nil?
                invalid.push(JSON.generate(item))
              end
            end
          end
        end
        
        if invalid.length>0
          return "#{@error_message} #{invalid.join(", ")}"
        end
  
        return nil
      end

    end
  end
end