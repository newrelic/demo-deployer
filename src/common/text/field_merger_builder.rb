require "./src/common/text/field_merger"

module Common
  module Text
    class FieldMergerBuilder

      def initialize()
        @merger = nil
        @definitions = Hash.new()
      end

      def create_definition(keys, value)
        key = get_formated_key(keys)
        @definitions[key] = value
        return self
      end

      def build()
        return (@merger ||= FieldMerger.new(@definitions))
      end

      private
      def get_formated_key(*parts)
        return "[" + parts.join(":") +"]"
      end

    end
  end
end