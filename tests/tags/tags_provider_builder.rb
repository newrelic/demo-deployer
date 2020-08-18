require "json"
require "./src/tags/orchestrator"

module Tests
  module Tags
    class TagsProviderBuilder

      def initialize(parent_builder)
        @parent_builder = parent_builder
        @content = {}
        @user_config = nil
      end

      def with(key, value)
        @content[key] = value
        return @parent_builder
      end

      def build(context)
        return @user_config ||= createInstance(context)
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
        orchestrator = ::Tags::Orchestrator.new(context)
        return orchestrator.execute(@content.to_json())
      end

    end
  end
end