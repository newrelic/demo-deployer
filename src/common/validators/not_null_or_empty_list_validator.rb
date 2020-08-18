require 'json'

module Common
  module Validators
    class NotNullOrEmptyListValidator
      
      def initialize(
        key,
        error_message = nil,
        not_null_or_empty_validator = NotNullOrEmptyValidator.new())

        @key = key
        @error_message = error_message || "Null or Empty"
        @not_null_or_empty_validator = not_null_or_empty_validator
      end

      def execute(items)
        missing = []

        (items || []).each do |item|
          value = item[@key]
          error = @not_null_or_empty_validator.execute(value)
          unless error.nil?
            missing.push(JSON.generate(item))
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