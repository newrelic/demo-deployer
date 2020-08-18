require "json"

module Common
  module Validators
    class ComparableArrayValidator
      def initialize(missing_error_message = nil)
        @error_message = missing_error_message || "Missing:"
      end

      def execute(sources, source_field_name, items, item_field_name = source_field_name)
        missing = []
        (sources || []).each do |source|
          begin
            if source.key?(source_field_name)
              source_value = source[source_field_name]
              found = (items || []).find {|item| item.key?(item_field_name) && item[item_field_name] == source_value}
              if found.nil?
                missing.push(JSON.generate(source))
              end            
            end
          rescue => exception
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