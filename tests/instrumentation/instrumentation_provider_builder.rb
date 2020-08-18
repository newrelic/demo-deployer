require "json"
require "./src/instrumentation/orchestrator"

module Tests
  module Instrumentation
    class InstrumentationProviderBuilder

      def initialize(parent_builder)
        @parent_builder = parent_builder
        @content = {}
        @provider = nil
      end

      def build(context)
        return @provider ||= createInstance(context)
      end

      def service(id, service_id, provider, local_source_path = "src/path", deploy_script_path = "deploy", version = "1.0", params = nil)
        instrumentations = get_or_create(@content, "instrumentations", {})
        services = get_or_create(instrumentations, "services", [])
        service = {}
        service["id"] = id
        service["service_ids"] = [service_id]
        service["provider"] = provider
        service["local_source_path"] = local_source_path
        service["deploy_script_path"] = deploy_script_path
        service["version"] = version
        unless params.nil?
          root = get_or_create(service, "params", {})
          params.each do |k,v|
            root[k] = v
          end
        end
        services.push(service)
      end
      
      def resource(id, resource_id, provider, local_source_path = "src/path", deploy_script_path = "deploy", version = "1.0", params = nil)
        instrumentations = get_or_create(@content, "instrumentations", {})
        resources = get_or_create(instrumentations, "resources", [])
        resource = {}
        resource["id"] = id
        resource["resource_ids"] = [resource_id]
        resource["provider"] = provider
        resource["local_source_path"] = local_source_path
        resource["deploy_script_path"] = deploy_script_path
        resource["version"] = version
        unless params.nil?
          root = get_or_create(resource, "params", {})
          params.each do |k,v|
            root[k] = v
          end
        end
        resources.push(resource)
      end

      private

      def get_or_create(instance, key, default)
        found = instance[key]
        if found.nil?
          instance[key] = default
        end
        return instance[key]
      end

      def createInstance(context)
        get_or_create(@content, "instrumentations", {})
        orchestrator = ::Instrumentation::Orchestrator.new(context, nil, nil, nil, false)
        return orchestrator.execute(@content.to_json())
      end

    end
  end
end