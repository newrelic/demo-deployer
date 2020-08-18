require "./src/common/tasks/process_task"
require "./src/common/text/credential_field_merger_builder"
require "./src/common/logger/logger_factory"

module Common
  module Io
    class GitProxy

      def initialize(context)
        @context = context
      end

      def clone(source_repository, destination_path)
        Common::Logger::LoggerFactory.get_logger().debug("Cloning Git repo #{source_repository} into #{destination_path}")
        field_merger = get_field_merger()
        repository = field_merger.merge(source_repository)
        process_command = "git clone #{repository}"
        path_to_source = get_path_to_source(source_repository, destination_path)
        if File.exist?(path_to_source)
          return path_to_source
        else
          if File.exist?(destination_path) == false
            FileUtils.mkdir_p(destination_path)
          end
          process_output = process_task(process_command, destination_path)      
          unless process_output.succeeded?
            command_output = process_output.get_stderr()
            raise Common::ValidationError.new("Failed to execute '#{process_command}'", [command_output]) 
          else
            return path_to_source
          end
        end
      end

      private

      def get_path_to_source(source_repository, destination_path)
        source_repo_name = File.basename(source_repository, ".git")
        path = "#{destination_path}/#{source_repo_name}"
        return path
      end

      def process_task(process_command, destination_path)
        task = Common::Tasks::ProcessTask.new(process_command, destination_path)
        process_output = task.wait_to_completion()
        return process_output
      end

      def get_field_merger()
        return @field_merger ||= Common::Text::CredentialFieldMergerBuilder.create(@context)
      end

    end
  end
end