require "./src/instrumentation/definitions/resource_instrumentor"
require "./src/instrumentation/definitions/service_instrumentor"
require "./src/instrumentation/definitions/global_instrumentor"
require "./src/common/text/global_field_merger_builder"

module Instrumentation
  class Provider

    def initialize(context, parsed_instrumentors, destination_path, resources, services, git_proxy)
      @context = context
      @parsed_instrumentors = parsed_instrumentors
      @destination_path = destination_path
      @resource_instrumentors = nil
      @service_instrumentors = nil
      @all_resource_instrumentors = nil
      @all_service_instrumentors = nil
      @resources = resources
      @services = services
      @git_proxy = git_proxy
    end

    def get_all()
      return @all_instrumentors ||= create_all_instrumentors()
    end

    def get_all_resource_instrumentors()
      return @all_resource_instrumentors ||= create_instrumentors("resources", "resource_ids", @resources, Instrumentation::Definitions::ResourceInstrumentor)
    end

    def get_all_service_instrumentors()
      return @all_service_instrumentors ||= create_instrumentors("services", "service_ids", @services, Instrumentation::Definitions::ServiceInstrumentor)
    end

    def get_all_global_instrumentors()
      return []
    end

    private
    def create_all_instrumentors()
      instrumentors = []
      instrumentors.concat(get_all_resource_instrumentors())
      instrumentors.concat(get_all_service_instrumentors())
      return instrumentors
    end

    def create_instrumentors(key, enum_key, items, type)
      instrumentors = []
      if @parsed_instrumentors.key?(key)
        @parsed_instrumentors[key].each do |parsed_instrumentor|
          merged_instrumentor = get_merged_instrumentor(parsed_instrumentor)
          keys = merged_instrumentor[enum_key]
          keys.each do |key|
            found = (items || []).find {|item| item.get_id() == key}
            unless found.nil?
              instrumentor = create(merged_instrumentor, type)
              instrumentor.set_item(found)
              instrumentors.push(instrumentor)
            else
              raise "Instrumentation error, could not find item with id: #{key}"
            end
          end
        end
      end
      return instrumentors.compact()
    end

    def create(merged_instrumentor, type)
      id = merged_instrumentor["id"]
      provider = merged_instrumentor["provider"]
      version = merged_instrumentor["version"]
      deploy_script_path = merged_instrumentor["deploy_script_path"]
      local_source_path = merged_instrumentor["local_source_path"]
      source_repository = merged_instrumentor["source_repository"]
      source_path = get_source_path(local_source_path, source_repository, id)
      instrumentor = type.new(
        id,
        provider,
        version,
        deploy_script_path,
        source_path)
      params = merged_instrumentor["params"]
      params = get_field_merger().merge_values(params)
      (params || {}).each do |k, v|
        instrumentor.get_params().add(k, v)
      end
      provider_credential = merged_instrumentor['provider_credential']
      unless provider_credential.nil?
        instrumentor.set_provider_credential(provider_credential)
      end
      return instrumentor
    end

    def get_repository_local_source_paths(source_repository, id)
      cloned_path = "#{@destination_path}/#{id}"
      cloned_source_path = get_git_proxy().clone(source_repository, cloned_path)
      return cloned_source_path
    end

    def get_source_path(local_source_path, source_repository, id)
      unless local_source_path.nil?()
        return local_source_path
      end
      return get_repository_local_source_paths(source_repository, id)
    end

    def get_git_proxy()
      return @git_proxy
    end

    def get_merged_instrumentor(parsed_instrumentor)
      return get_field_merger().merge_values(parsed_instrumentor)
    end

    def get_field_merger()
      return @field_merger ||= Common::Text::GlobalFieldMergerBuilder.create(@context)
    end

  end
end