require "json"

module Common
  module Validators
    class UniqueIdValidator

      def initialize(field_name, error_message = nil)
        @field_name = field_name
        @error_message = error_message || "Duplicate ids found:"
      end

      def execute(items)
        invalid = []
        items_grouped_by_ids = (items ||= [])
              .select { |item| !item[@field_name].nil? }
              .group_by { |item| item[@field_name].downcase() }
              .values

        items_grouped_by_ids.each do |item|
          if item.count > 1
            items = item.collect {|item| JSON.generate(item)}
            invalid.push("#{items.join('|')}")
          end
        end

        if invalid.length > 0
          message = invalid.join(", ")
          return "#{@error_message} #{message}"
        end
        return nil
      end

    end
  end
end