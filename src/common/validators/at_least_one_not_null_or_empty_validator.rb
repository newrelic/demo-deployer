require 'json'

module Common
  module Validators
    class AtLeastOneNotNullOrEmptyValidator
      
      def initialize(
        keys,
        error_message = nil,
        not_null_or_empty_validator = NotNullOrEmptyValidator.new())

        @keys = keys
        @error_message = error_message || "At least 1 not Null or Empty"
        @not_null_or_empty_validator = not_null_or_empty_validator
      end

      def execute(items)
        missing = []

        (items || []).each do |item|
          unless has_at_least_one_defined(item)
            missing.push(JSON.generate(item))
          end
        end
        
        if missing.length>0
          return "#{@error_message} having any #{(@keys||[]).join(", ")} but found #{missing.join(", ")}"
        end
  
        return nil
      end

      private
      def has_at_least_one_defined(item)
        (@keys || []).each do |key|
          if item.key?(key)
            value = item[key]
            error = @not_null_or_empty_validator.execute(value)
            if error.nil?
              return true
            end
          end
        end
        return false
      end

    end
  end
end