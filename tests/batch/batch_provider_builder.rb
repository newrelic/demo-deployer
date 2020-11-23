require "json"
require "./src/batch/provider"

module Tests
  module Batch
    class BatchProviderBuilder

      def initialize(parent_builder)
        @parent_builder = parent_builder
      end

      def build(context)
        return @provider ||= createInstance(context)
      end

      private

      def createInstance(context)
        provider = ::Batch::Provider.new(context)
        context.set_batch_provider(provider)
        return provider
      end

    end
  end
end