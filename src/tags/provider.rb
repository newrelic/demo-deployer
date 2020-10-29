require "./src/common/text/credential_field_merger_builder"

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
      tags = get_merged_tags(tags)
      return tags
    end

    def get_service_tags(service_id)
      service_tags = @services_tags[service_id] || {}
      tags = @global_tags.merge(service_tags)
      deployment_name_tag = get_deployment_tags()
      tags = tags.merge(deployment_name_tag)
      tags = get_merged_tags(tags)
      return tags
    end
  
    def get_global_tags() 
      tags = @global_tags.merge({})
      tags = tags.merge(get_deployment_tags())
      tags = get_merged_tags(tags)
      return tags
    end

    private
    def get_deployment_tags()
      tags = { 
        "dxDeploymentName" => "[global:deployment_name]",
        "dxDeploymentDate" => Date.today.to_s,
        "dxDeployerVersion" => "3.0.0",
        "dxDeployedBy" => "[global:user_name]"
      }
      return tags
    end

    def get_merged_tags(tags)
      merger = Common::Text::CredentialFieldMergerBuilder.create(@context)
      return merger.merge_values(tags)
    end

  end
end
