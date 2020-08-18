require 'json'

module Common
  module Validators
    class AtMostOneNotNullAndDefinedValidator
      
      def initialize(
        keys,
        error_message = nil,
        not_null_or_empty_validator = NotNullOrEmptyValidator.new())

        @keys = keys
        @error_message = error_message || "At most 1 not Null and Defined"
        @not_null_or_empty_validator = not_null_or_empty_validator
      end

      def execute(items)
        invalid = []

        (items || []).each do |item|
          if has_more_than_one_defined(item)
            invalid.push(JSON.generate(item))
          end
        end
        
        if invalid.length>0
          return "#{@error_message} with keys #{(@keys||[])} and #{invalid.join(", ")}"
        end
  
        return nil
      end

      private
      def has_more_than_one_defined(item)
        groups = (@keys ||= []).group_by { |key| @not_null_or_empty_validator.execute(item[key]).nil? }
        groups.each { |key, values|
          if key == true
            return values.count > 1
          end 
        }
        return false
      end

    end
  end
end