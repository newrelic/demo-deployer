
module Common
  module Validators
    class KeyValueMaxLengthValidator

      def initialize(key_max_length, value_max_length, error_message = nil)
        @key_max_length = key_max_length
        @value_max_length = value_max_length
        @error_message = error_message
      end

      def execute(items)
        invalid_key_value_pair = []
        (items || []).each do |key, value|
          if (!key.nil?   && key.length   > @key_max_length) ||
             (!value.nil? && value.length > @value_max_length)
            invalid_key_value_pair.push("{#{key}: #{value}}")
          end
        end

        if invalid_key_value_pair.length > 0
          message = invalid_key_value_pair.join(", ")
          return "#{@error_message} #{message}"
        else
          return nil
        end
      end

    end
  end
end