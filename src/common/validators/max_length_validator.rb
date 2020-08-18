require 'json'

module Common
  module Validators
    class MaxLengthValidator

      def initialize(field_name, max_length, error_message)
        @field_name = field_name
        @max_length = max_length
        @error_message = error_message
      end

      def execute(items)
        invalid = []
        (items || []).each do |item|
          value = item[@field_name]

          if !value.nil? &&  value.length > @max_length
            invalid.push(JSON.generate(item))
          end

          if invalid.length > 0
            message = invalid.join(", ")
            return "#{@error_message} #{message}"
          else
            return nil
          end
        end
      end

    end
  end
end