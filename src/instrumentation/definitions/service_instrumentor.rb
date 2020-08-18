require './src/instrumentation/definitions/instrumentor'

module Instrumentation
  module Definitions
    class ServiceInstrumentor < Instrumentation::Definitions::Instrumentor

      def initialize (id, service, provider, version, deploy_script_path, source_path)
        super(id, service.get_id(), provider, version, deploy_script_path, source_path)
        @service = service
      end

      def get_service()
        return @service
      end

      def get_identity()
        return "si-#{get_id()}"
      end

      def ==(other)
        return match_by_identity(other.get_identity())
      end

      def to_s()
        return "ServiceInstrumentor id:#{get_id()} service_id:#{get_item_id()}"
      end

    end
  end
end
