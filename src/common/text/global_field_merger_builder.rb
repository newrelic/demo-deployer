require_relative "field_merger_builder"

module Common
  module Text
    class GlobalFieldMergerBuilder
      def initialize(field_merger_builder = nil)
        @field_merger_builder = field_merger_builder || Common::Text::FieldMergerBuilder.new()
      end

      def build()
        return @field_merger_builder.build()
      end

      def with_deployment_name(context)
        deployment_name = context.get_command_line_provider().get_deployment_name()
        @field_merger_builder.create_definition(["deployment_name"], deployment_name)
      end

      def self.create(context)
        instance = GlobalFieldMergerBuilder.new()
        return instance.build()
      end

    end
  end
end