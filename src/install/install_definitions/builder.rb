require "./src/common/logger/logger_factory"
require './src/common/io/directory_service'
require './src/common/install/definitions/install_definition'
require './src/install/mappers/relationship_mapper'
require './src/install/mappers/endpoint_mapper'

module Install
  module InstallDefinitions
    class Builder

      def initialize(context, provisioned_resources)
        @context = context
        @provisioned_resources = provisioned_resources
      end

      def build()
        return build_install_definitions()
      end

      protected
      def is_resource_included(resource_id)
        provisioned_resource = get_provision_resource(resource_id)
        unless provisioned_resource.nil?
          return true
        end
        return false
      end

      def get_service_credential(service)
        credential = nil
        provider_credential = service.get_provider_credential()
        unless (provider_credential.nil?)
          credential = get_user_config_provider().get_credential(provider_credential)
        end
        return credential
      end

      def get_instrumentor_credential(instrumentor)
        credential = nil
        provider = instrumentor.get_provider()
        unless (provider.nil?)
          credential = get_user_config_provider().get_credential(provider)
        end
        return credential
      end

      def get_instrumentor_provider_credential(instrumentor)
        credential = nil
        provider = instrumentor.get_provider_credential()
        unless (provider.nil?)
          credential = get_user_config_provider().get_credential(provider)
        end
        return credential
      end

      def collect_params(resource_ids)
        params = {}
        resource_ids.each do |resource_id|
          provisioned_resource = get_provision_resource(resource_id)
          unless provisioned_resource.nil?
            provisioned_resource.get_params().get_all().each do |key,value|
              params[key] = value
            end
          end
        end
        return params
      end

      def get_roles_path(entity)
        roles_path = entity.get_deploy_script_full_path()
        path = get_app_config_provider().get_ansible_roles_path()
        if path != nil
          roles_path = "#{roles_path}:#{path}"
        end
        Common::Logger::LoggerFactory.get_logger().debug("Building roles_path:#{roles_path} using path:#{path}")
        return roles_path
      end

      def get_deployment_name()
        return @deployment_name ||= get_command_line_provider().get_deployment_name()
      end

      def get_services()
        return @services ||= get_services_provider().get_services()
      end

      def get_provision_provider()
        return @provision_provider ||= @context.get_provision_provider()
      end

      def get_provision_resource(resource_id)
        return (@provisioned_resources || []).find { |provisioned_resource| provisioned_resource.match_by_id(resource_id) }
      end

      def get_user_config_provider()
        return @user_config_provider ||= @context.get_user_config_provider()
      end

      def get_app_config_provider()
        return @app_config_provider ||= @context.get_app_config_provider()
      end

      def get_command_line_provider()
        return @command_line_provider ||= @context.get_command_line_provider()
      end

      def get_services_provider()
        return @services_provider ||= @context.get_services_provider()
      end

      def get_deployment_path()
        return @deployment_path ||= "#{get_execution_path()}/#{get_deployment_name()}"
      end

      def get_erb_input_path()
        return "src/common/install/templates"
      end

      def get_execution_path()
        return @execution_path ||= get_app_config_provider().get_execution_path()
      end

      def get_relationship_mapper()
        return @relationship_mapper ||= Install::Mappers::RelationshipMapper.new(@context.get_services_provider(), @context.get_provision_provider())
      end

      def get_endpoint_mapper()
        return @endpoint_mapper ||= Install::Mappers::EndpointMapper.new(@context.get_services_provider(), @context.get_provision_provider())
      end

      def get_relationships(service)
        return get_relationship_mapper().build_relationship_map(service)
      end

      def get_endpoints(service)
        return get_endpoint_mapper().build_endpoint_map(service)
      end

      def get_service_instrumentors()
        return @service_instrumentors ||= @context.get_instrumentation_provider().get_all_service_instrumentors()
      end

      def get_resource_instrumentors()
        return @resource_instrumentors ||= @context.get_instrumentation_provider().get_all_resource_instrumentors()
      end

    end
  end
end