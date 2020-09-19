require './src/common/install/definitions/install_definition'
require './src/install/install_definitions/builder'
require "./src/common/logger/logger_factory"

module Install
  module InstallDefinitions
    class OnHostInstrumentationBuilder < Builder

      def initialize(context, provisioned_resources)
        super(context, provisioned_resources)
      end

      def build_install_definitions()
        install_definitions = []
        resource_instrumentors = get_resource_instrumentors()
        Common::Logger::LoggerFactory.get_logger().debug("OnHostInstrumentationBuilder for #{resource_instrumentors.length} resource instrumentors")
        resource_instrumentors.each do |resource_instrumentor|
          resource_id = resource_instrumentor.get_resource().get_id()
          if is_resource_included(resource_id)
            Common::Logger::LoggerFactory.get_logger().debug("OnHostInstrumentationBuilder building definitions for resource #{resource_id}")
            instrumentor_install_definition = assemble_install_definition(resource_instrumentor)
            install_definitions.push(instrumentor_install_definition)
          end
        end
        return install_definitions
      end

      private
      def assemble_install_definition(instrumentor, params = {})
        resource_id = instrumentor.get_resource().get_id()
        provisioned_resource = get_provision_resource(resource_id)
        roles_path = get_roles_path(instrumentor)
        yaml_output_path = get_yaml_output_path(instrumentor, resource_id)
        action_vars_lambda = lambda { return get_action_vars(instrumentor, provisioned_resource, params) }
        return Common::Install::Definitions::InstallDefinition.new(provisioned_resource, get_erb_input_path(), yaml_output_path, roles_path, action_vars_lambda)
      end

      def get_action_vars(instrumentor, provisioned_resource, params = {})
        resource_id = provisioned_resource.get_resource().get_id()
        tags = provisioned_resource.get_resource().get_tags().to_json()
        deployment_name = get_deployment_name()
        vars = {}
        vars["resource_id"] = resource_id
        vars["version"] = instrumentor.get_version()
        vars["remote_user"] = provisioned_resource.get_user_name()
        vars["resource_display_name"] = provisioned_resource.get_resource().get_display_name()
        vars["deployment_name"] = deployment_name
        vars["deployment_path"] = get_deployment_path()
        vars["resource_deployment_name"] = "#{deployment_name}_#{resource_id}"
        vars["tags"] = tags
        credential = get_instrumentor_credential(instrumentor)
        unless (credential.nil?)
          vars = vars.merge(credential.to_h())
        end
        credential = get_instrumentor_provider_credential(instrumentor)
        unless (credential.nil?)
          vars = vars.merge(credential.to_h())
        end
        vars = vars.merge(params)
        instrumentor_params = instrumentor.get_params().get_all()
        vars = vars.merge(instrumentor_params)
        return vars
      end

      def get_yaml_output_path(instrumentor, resource_id)
        return "#{get_deployment_name()}/#{resource_id}/#{instrumentor.get_id()}"
      end

    end
  end
end