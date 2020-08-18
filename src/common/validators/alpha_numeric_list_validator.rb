require 'json'

require_relative 'alpha_numeric'

module Common
  module Validators
    class AlphaNumericListValidator
      
      def initialize(
        key,
        error_message = nil,
        alphanumeric_validator = AlphaNumeric.new())

        @key = key
        @error_message = error_message || "Null or Empty"
        @alphanumeric_validator = alphanumeric_validator
      end

      def execute(items)
        missing = []

        (items || []).each do |item|
          value = item[@key]
          error = @alphanumeric_validator.execute(value)
          unless error.nil?
            missing.push(error)
          end
        end
        
        if missing.length>0
          return "#{@error_message} #{missing.join(", ")}"
        end
  
        return nil
      end

    end
  end
end