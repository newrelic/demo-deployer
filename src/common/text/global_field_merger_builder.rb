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

      def with_deployment_names(context)
        deployment_name = context.get_command_line_provider().get_deployment_name()
        @field_merger_builder.create_definition(["global","deployment_name"], deployment_name)

        username = context.get_command_line_provider().get_user_config_name()
        @field_merger_builder.create_definition(["global","user_name"], username)

        deployname = context.get_command_line_provider().get_deploy_config_name()
        @field_merger_builder.create_definition(["global","deploy_name"], deployname)
      end

      def with_env_var(context)
        @field_merger_builder.create_definition(["env","*"], "")
      end

      def self.create(context)
        instance = GlobalFieldMergerBuilder.new()
        instance.with_deployment_names(context)
        instance.with_env_var(context)
        return instance.build()
      end

    end
  end
end