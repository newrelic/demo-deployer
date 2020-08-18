require "json"
require "./src/app_config/orchestrator"

module Tests
  module AppConfig
    class AppConfigProviderBuilder

      def initialize(parent_builder)
        @parent_builder = parent_builder
        @content = {}
        @provider = nil
      end

      def with(key, value)
        @content[key] = value
        return @parent_builder
      end

      def build(context)
        return @provider ||= createInstance(context)
      end

      private
      def createInstance(context)
        orchestrator = ::AppConfig::Orchestrator.new(context, nil, nil, false)
        return orchestrator.execute(@content)
      end

    end
  end
end