require "json"
require "mocha/mock"
require "./src/services/orchestrator"

module Tests
  module Services
    class ServicesProviderBuilder

      def initialize(parent_builder)
        @parent_builder = parent_builder
        @content = {}
        @provider = nil
      end

      def build(context)
        return @provider ||= createInstance(context)
      end

      def service(id, port, local_source_path, deploy_script_path, reference_ids = nil)
        service = create_new_service(id)
        service["port"] = port
        service["local_source_path"] = local_source_path
        service["deploy_script_path"] = deploy_script_path
        unless reference_ids.nil?
          destinations = get_or_create(service, "destinations", [])
          (reference_ids || []).compact().each do |reference_id|
            destinations.push(reference_id)
          end
        end
        return @parent_builder
      end
      
      def lambda(id, local_source_path, deploy_script_path, reference_id)
        service = create_new_service(id)
        service["local_source_path"] = local_source_path
        service["deploy_script_path"] = deploy_script_path
        destinations = get_or_create(service, "destinations", [])
        destinations.push(reference_id)
        return @parent_builder
      end

      private

      def create_new_service(id)
        services = get_or_create(@content, "services", [])
        service = {}
        service["id"] = id
        services.push(service)
        return service
      end

      def get_or_create(instance, key, default)
        found = instance[key]
        if found.nil?
          instance[key] = default
        end
        return instance[key]
      end

      def createInstance(context)
        get_or_create(@content, "services", [])
        directory_copier_stub = Mocha::Mock.new("DirectoryCopierMock")
        directory_copier_stub.stubs(:copy).returns("")
        orchestrator = ::Services::Orchestrator.new(context, nil, nil, nil, directory_copier_stub, false)
        return orchestrator.execute(@content.to_json())
      end

    end
  end
end