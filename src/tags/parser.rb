require 'json'
require_relative "parsed_output"

module Tags
  class Parser

    def execute(config)
      global_tags = parse_global(config)
      resources_tags = parse_resources(config)
      services_tags = parse_services(config)
      return ParsedOutput.new(global_tags, services_tags, resources_tags)
    end

    private
    def parse_global(config)
      unless config.nil?
        config_json = JSON.parse(config)
        return config_json['global_tags'] || {}
      else
        return {}
      end
    end

    def parse_resources(config)
      resources_tags = {}
      unless config.nil?
        config_json = JSON.parse(config)
        resources = config_json['resources'] || []
        resources.each do |resource|
          resource_id = resource["id"]
          unless resource_id.nil?
            resource_tags = resource["tags"] || {}
            resources_tags[resource_id] = resource_tags
          end
        end
      end
      return resources_tags
    end

    def parse_services(config)
      services_tags = {}
      unless config.nil?
        config_json = JSON.parse(config)
        services = config_json['services'] || []
        services.each do |service|
          service_id = service["id"]
          unless service_id.nil?
            service_tags = service["tags"] || {}
            services_tags[service_id] = service_tags
          end
        end
      end
      return services_tags
    end

  end
end