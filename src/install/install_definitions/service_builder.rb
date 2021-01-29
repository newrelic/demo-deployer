require './src/common/io/directory_service'
require './src/common/install/definitions/install_definition'
require './src/install/install_definitions/builder'

module Install
  module InstallDefinitions
    class ServiceBuilder < Builder

      def initialize(context, provisioned_resources)
        super(context, provisioned_resources)
      end

      def build_install_definitions()
        install_definitions = []
        services = get_services()
        Common::Logger::LoggerFactory.get_logger().debug("ServiceBuilder for #{services.length} services")
        services.each do |service|
          deploy_host = service.get_deploy_host()
          if deploy_host.nil?
            service.get_destinations().each do |resource_id|
              if is_resource_included(resource_id)
                Common::Logger::LoggerFactory.get_logger().debug("ServiceBuilder building definitions for service #{service.get_id()} on resource #{resource_id}")
                params = collect_params(service.get_destinations())
                service_install_definition = assemble_install_definition(service, resource_id, params)
                install_definitions.push(service_install_definition)
              end
            end
          else
            if is_resource_included(deploy_host)
              Common::Logger::LoggerFactory.get_logger().debug("ServiceBuilder building definitions for service #{service.get_id()} with deploy host #{deploy_host}")
              params = collect_params(service.get_destinations())
              service_install_definition = assemble_install_definition(service, deploy_host, params)
              install_definitions.push(service_install_definition)
            end
          end
        end
        return install_definitions
      end

      private
      def assemble_install_definition(service, resource_id, params = {})
        provisioned_resource = get_provision_resource(resource_id)
        roles_path = get_roles_path(service)
        yaml_output_path = get_yaml_output_path(service, resource_id)
        action_vars_lambda = lambda { return get_action_vars(service, provisioned_resource, params) }
        output_params = service.get_params()
        service_id = service.get_id()
        return Common::Install::Definitions::InstallDefinition.new(service_id, provisioned_resource, get_erb_input_path(), yaml_output_path, roles_path, action_vars_lambda, output_params)
      end

      def get_action_vars(service, provisioned_resource, params)
        dependencies = get_relationships(service).to_json()
        deployment_name = get_deployment_name()
        vars = {}
        vars["service_id"] = service.get_id()
        vars["service_port"] = service.get_port()
        vars["remote_user"] = provisioned_resource.get_user_name()
        vars["dependencies"] = dependencies
        vars["endpoints"] = get_endpoints(service)
        vars["deployment_name"] = deployment_name
        vars["deployment_path"] = get_deployment_path()
        vars["service_deployment_name"] = "#{deployment_name}_#{service.get_id()}"

        credential = get_service_credential(service)
        unless (credential.nil?)
          vars = vars.merge(credential.to_h())
        end
        vars = vars.merge(params)
        service_params = service.get_params().get_all()
        vars = vars.merge(service_params)
        return vars
      end

      def get_yaml_output_path(service, resource_id)
        return "#{get_deployment_name()}/#{service.get_id()}/#{resource_id}"
      end

    end
  end
end