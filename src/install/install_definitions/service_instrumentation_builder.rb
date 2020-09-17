require './src/common/io/directory_service'
require './src/common/install/definitions/install_definition'
require './src/install/install_definitions/builder'

module Install
  module InstallDefinitions
    class ServiceInstrumentationBuilder < Builder

      def initialize(context, provisioned_resources)
        super(context, provisioned_resources)
      end

      def build_install_definitions()
        install_definitions = []
        service_instrumentors = get_service_instrumentors()
        Common::Logger::LoggerFactory.get_logger().debug("ServiceInstrumentationBuilder for #{service_instrumentors.length} service instrumentors")
        service_instrumentors.each do |service_instrumentor|
          service = service_instrumentor.get_service()
          deploy_host = service.get_deploy_host()
          if deploy_host.nil?
            service.get_destinations().each do |resource_id|
              if is_resource_included(resource_id)
                Common::Logger::LoggerFactory.get_logger().debug("ServiceInstrumentationBuilder building definitions for service #{service.get_id()} on resource #{resource_id}")
                install_definition = assemble_install_definition(service_instrumentor, resource_id)
                install_definitions.push(install_definition)
              end
            end
          else
            if is_resource_included(deploy_host)
              Common::Logger::LoggerFactory.get_logger().debug("ServiceInstrumentationBuilder building definitions for service #{service.get_id()} with deploy host #{deploy_host}")
              params = collect_params(service.get_destinations())
              install_definition = assemble_install_definition(service_instrumentor, deploy_host, params)
              install_definitions.push(install_definition)
            end
          end
        end
        return install_definitions
      end

      private
      def assemble_install_definition(instrumentor, resource_id, params = {})
        service = instrumentor.get_service()
        provisioned_resource = get_provision_resource(resource_id)
        roles_path = get_roles_path(instrumentor)
        yaml_output_path = get_yaml_output_path(instrumentor, service, resource_id)
        action_vars_lambda = lambda { return get_action_vars(instrumentor, service, provisioned_resource, params) }
        output_params = service.get_params()
        return Common::Install::Definitions::InstallDefinition.new(provisioned_resource, get_erb_input_path(), yaml_output_path, roles_path, action_vars_lambda, output_params)
      end

      def get_action_vars(instrumentor, service, provisioned_resource, params = {})
        deployment_name = get_deployment_name()
        tags = service.get_tags().to_json()
        vars = {}
        vars["service_id"] = service.get_id()
        vars["agent_version"] = instrumentor.get_version()
        vars["remote_user"] = provisioned_resource.get_user_name()
        vars["service_display_name"] = service.get_display_name()
        vars["deployment_name"] = deployment_name
        vars["deployment_path"] = get_deployment_path()
        vars["service_deployment_name"] = "#{deployment_name}_#{service.get_id()}"
        vars["tags"] = tags
        credential = get_instrumentor_credential(instrumentor)
        unless (credential.nil?)
          vars = vars.merge(credential.to_h())
        end
        credential = get_instrumentor_provider_credential(instrumentor)
        unless (credential.nil?)
          vars = vars.merge(credential.to_h())
        end
        credential = get_service_credential(service)
        unless (credential.nil?)
          vars = vars.merge(credential.to_h())
        end
        vars = vars.merge(params)
        service_params = service.get_params().get_all()
        vars = vars.merge(service_params)
        instrumentor_params = instrumentor.get_params().get_all()
        vars = vars.merge(instrumentor_params)
        return vars
      end

      def get_yaml_output_path(instrumentor, service, resource_id)
        return "#{get_deployment_name()}/#{service.get_id()}/#{resource_id}/#{instrumentor.get_id()}"
      end

    end
  end
end
