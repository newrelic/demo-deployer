require "json"
require "./src/command_line/orchestrator"

module Tests
  module CommandLine
    class CommandLineProviderBuilder

      def initialize(parent_builder)
        @parent_builder = parent_builder
        @arguments = []
        @provider = nil
      end

      def user_config(filename)
        @arguments.push("-c")
        @arguments.push(filename)
        return @parent_builder
      end

      def deploy_config(filename)
        @arguments.push("-d")
        @arguments.push(filename)
        return @parent_builder
      end

      def trace(level)
        @arguments.push("-l")
        @arguments.push(level)
        return @parent_builder
      end

      def teardown()
        @arguments.push("-t")
        return @parent_builder
      end

      def build(context)
        return @provider ||= createInstance(context)
      end

      private

      def createInstance(context)
        orchestrator = ::CommandLine::Orchestrator.new(context, nil, nil, nil, false)
        unless @arguments.include?("-c")
          deploy_config("user_config_filename.json")
        end
        unless @arguments.include?("-d")
          deploy_config("deploy_config_filename.json")
        end
        unless @arguments.include?("-l")
          trace("error")
        end
        return orchestrator.execute(@arguments)
      end

    end
  end
end