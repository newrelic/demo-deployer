require 'json'
require "./src/services/definitions/service"
require "./src/services/definitions/file"

module Services
  class Provider

    def initialize(services, source_paths_file, tags_provider)
      @services = services
      @source_paths_file = source_paths_file
      @tags_provider = tags_provider
    end
    
    def get_all()
      return get_services()
    end
    
    def get_services()
      @service_definitions ||= build_service_definitions()
      return @service_definitions
    end

    def get_all_service_ids()
      return get_services().map { |service| service.get_id() }
    end

    def get_by_id(id)
      return get_services().find { |service| service.match_by_id(id) }
    end

    def aggregate_value(destination_id)
      values = []

      get_services().each do |service|
        service.get_destinations().each do |service_destination_id|
          if destination_id == service_destination_id
            value = yield(service)
            values.push(value)
          end
        end
      end
      return values.compact()
    end

    private

    def build_service_definitions()
      service_definitions = []
      @services.each do |service|
        id = service['id']
        display_name = service['display_name']
        port = service['port']
        destinations = service['destinations']
        source_path = @source_paths_file[id]
        deploy_script_path = service['deploy_script_path']
        relationships = service['relationships'] || []
        endpoints = service['endpoints'] || []
        deploy_host = service['deploy_host']
        provider_credential = service['provider_credential']	
        service_definition = Definitions::Service.new(id, display_name, port, destinations, source_path, deploy_script_path, relationships, endpoints, deploy_host, provider_credential)
        files = get_files(service['files'] || [])
        service_definition.add_files(files)
        tags = @tags_provider.get_service_tags(id)
        service_definition.add_tags(tags)
        params = service["params"]
        (params || {}).each do |k, v|
          service_definition.get_params().add(k, v)
        end
        service_definitions.push(service_definition)
      end
      return service_definitions
    end

    def get_files(raw_files)
      files = []
      raw_files.each do |raw_file|
        destination_filepath = raw_file['destination_filepath']
        content = raw_file['content']
        unless content.nil?
          if destination_filepath!=nil && destination_filepath.downcase().end_with?(".json") && destination_filepath.downcase().start_with?("http")==false
            content = JSON.pretty_generate(content)
          end
        end
        file = Definitions::File.new(destination_filepath, content)
        files.push(file)
      end
      return files
    end

  end
end