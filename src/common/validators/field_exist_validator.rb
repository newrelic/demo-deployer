require "json"

module Common
  module Validators
    class FieldExistValidator
      def initialize(field_name, error_message = nil)
        @field_name = field_name
        @error_message = error_message || "Missing #{field_name}"
      end

      def execute(items)
        missing = []
        (items || []).each do |item|
          value = item[@field_name.to_s] || item[@field_name.to_sym]
          if value.nil? || value.empty?
            missing.push(JSON.generate(item))
          end
        end
        if missing.length>0
          message = missing.join(", ")
          return "#{@error_message} #{message}"
        end
        return nil
      end

    end
  end
end