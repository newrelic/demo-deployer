require "./src/infrastructure/definitions/resource_factory"
require "./src/common/text/global_field_merger_builder"

module Infrastructure
  class Provider

    def initialize(
        context,
        parsed_resources,
        resource_factory = nil)
        @context = context
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
        merged_resource = get_merged_resource(parsed_resource)
        resource = get_resource_factory().create(merged_resource)
        resources.push(resource)
      end
      return resources.compact()
    end

    def get_merged_resource(parsed_resource)
      merger = Common::Text::GlobalFieldMergerBuilder.create(@context)
      return merger.merge_values(parsed_resource)
    end

    def get_tags_provider()
      return @context.get_tags_provider()
    end

    def get_user_config_provider()
      return @context.get_user_config_provider()
    end

    def get_resource_factory()
      return @resource_factory ||= Infrastructure::Definitions::ResourceFactory.new(get_user_config_provider(), get_tags_provider())
    end

  end
end