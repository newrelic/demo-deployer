module Tags
  class Provider

    def initialize(context, global_tags = nil, services_tags = nil, resources_tags = nil)
      @context = context
      @global_tags = global_tags || {}
      @services_tags = services_tags || {}
      @resources_tags = resources_tags || {}
    end

    def get_resource_tags(resource_id)
      resource_tags = @resources_tags[resource_id] || {}
      tags = @global_tags.merge(resource_tags)
      deployment_name_tag = get_deployment_tags()
      tags = tags.merge(deployment_name_tag)
      return tags
    end

    def get_service_tags(service_id)
      service_tags = @services_tags[service_id] || {}
      tags = @global_tags.merge(service_tags)
      deployment_name_tag = get_deployment_tags()
      tags = tags.merge(deployment_name_tag)
      return tags
    end

    private
    def get_deployment_tags()
      command_line_provider = @context.get_command_line_provider()
      deployment_name = command_line_provider.get_deployment_name()
      username = command_line_provider.get_user_config_name()
      tags = { 
        "dxDeploymentName" => deployment_name,
        "dxDeploymentDate" => Date.today.to_s,
        "dxDeployerVersion" => "3.0.0",
        "dxDeployedBy" => username
      }
      return tags
    end

  end
end