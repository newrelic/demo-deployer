require './src/common/install/definitions/install_definition'
require './src/install/install_definitions/builder'
require "./src/common/logger/logger_factory"

module Install
  module InstallDefinitions
    class GlobalInstrumentationBuilder < Builder

      def initialize(context, provisioned_resources)
        super(context, provisioned_resources)
      end

      def build_install_definitions()
        install_definitions = []
        global_instrumentors = get_global_instrumentors()
        Common::Logger::LoggerFactory.get_logger().debug("GlobalInstrumentationBuilder for #{global_instrumentors.length} global instrumentors")
        global_instrumentors.each do |global_instrumentor|
            Common::Logger::LoggerFactory.get_logger().debug("GlobalInstrumentationBuilder building definitions for global #{global_instrumentor.get_id()}")
            instrumentor_install_definition = assemble_install_definition(global_instrumentor)
            install_definitions.push(instrumentor_install_definition)
        end
        return install_definitions
      end

      private
      def assemble_install_definition(instrumentor, params = {})
        global_id = instrumentor.get_id()
        roles_path = get_roles_path(instrumentor)
        yaml_output_path = get_yaml_output_path(instrumentor)
        action_vars_lambda = lambda { return get_action_vars(instrumentor, params) }
        # Don't forget to pass the global instrumentationn to the install definition
        return Common::Install::Definitions::InstallDefinition.new(nil, get_erb_input_path(), yaml_output_path, roles_path, action_vars_lambda)
      end

      def get_action_vars(instrumentor, params = {})
        tags = @context.get_tags_provider().get_global_tags().to_json()
        deployment_name = get_deployment_name()
        vars = {}
        vars["version"] = instrumentor.get_version()
        vars["deployment_name"] = deployment_name
        vars["deployment_path"] = get_deployment_path()
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

      def get_yaml_output_path(instrumentor)
        return "#{get_deployment_name()}/global/#{instrumentor.get_id()}"
      end

    end
  end
end