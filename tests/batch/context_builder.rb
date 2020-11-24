require "./src/batch/context"
require "./tests/app_config/app_config_provider_builder"

require_relative "command_line/command_line_provider_builder"
require_relative "batch_provider_builder"

module Tests
  module Batch
    class ContextBuilder

      def initialize()
        @context = nil
        @command_line_provider_builder = Batch::CommandLine::CommandLineProviderBuilder.new(self)
        @app_config_provider_builder = Tests::AppConfig::AppConfigProviderBuilder.new(self)
        @batch_provider_builder = Batch::BatchProviderBuilder.new(self)
        # Defaulting
        @command_line_provider_builder.user_config("user.json")
        @command_line_provider_builder.deploy_config("deploy.json")
      end

      def command_line()
        return @command_line_provider_builder
      end

      def app_config()
        return @app_config_provider_builder
      end

      def batch_provider_builder()
        return @batch_provider_builder
      end

      def build()
        return @context ||= createInstance()
      end

      private
      def createInstance()
        context = ::Batch::Context.new()
        @command_line_provider_builder.build(context)
        @app_config_provider_builder.build(context)
        @batch_provider_builder.build(context)
        return context
      end

    end
  end
end