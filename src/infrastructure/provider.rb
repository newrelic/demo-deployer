require "./src/infrastructure/definitions/resource_factory"

module Infrastructure
  class Provider

    def initialize(
        parsed_resources,
        user_config_provider,
        tag_provider,
        resource_factory = Infrastructure::Definitions::ResourceFactory.new(user_config_provider, tag_provider))
      @parsed_resources = parsed_resources
      @resource_factory = resource_factory
    end

    def get_by_id(id)
      return get_all().find { |resource| resource.match_by_id(id) }
    end

    def get_all()
      return @resources ||= create()
    end

    def get_all_resource_ids()
      return get_all().map { |resource| resource.get_id() }
    end

    def get_provider_names()
      return get_all().map { |resource| resource.get_provider() }
    end

    def partition_by_provision_group()
      grouped = get_all().group_by { |resource| resource.get_provision_group() }
      sorted = grouped.sort().to_h()
      return sorted.values()
    end

    private
    def create()
      resources = []
      @parsed_resources.each do |parsed_resource|
        resource = @resource_factory.create(parsed_resource)
        resources.push(resource)
      end
      return resources.compact()
    end

  end
end