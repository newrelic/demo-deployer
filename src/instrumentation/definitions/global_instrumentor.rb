require './src/instrumentation/definitions/instrumentor'

module Instrumentation
  module Definitions
    class GlobalInstrumentor < Instrumentation::Definitions::Instrumentor

      def initialize (id, provider, version, deploy_script_path, source_path)
        super(id, provider, version, deploy_script_path, source_path)
      end

      def get_identity()
        return "gi-#{get_id()}"
      end

      def ==(other)
        return match_by_identity(other.get_identity())
      end

      def to_s()
        return "GlobalInstrumentor id:#{get_id()}"
      end

    end
  end
end
