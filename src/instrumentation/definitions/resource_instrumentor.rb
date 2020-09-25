require './src/instrumentation/definitions/instrumentor'

module Instrumentation
  module Definitions
    class ResourceInstrumentor < Instrumentation::Definitions::Instrumentor

      def initialize (id, resource, provider, version, deploy_script_path, source_path)
        super(id, provider, version, deploy_script_path, source_path)
        @resource = resource
      end

      def get_resource()
        return @resource
      end

      def get_identity()
        return "ri-#{get_id()}"
      end

      def get_item_id()
        return @resource.get_id()
      end

      def ==(other)
        return match_by_identity(other.get_identity())
      end

      def to_s()
        return "ResourceInstrumentor id:#{get_id()} resource_id:#{get_item_id()}"
      end

    end
  end
end
