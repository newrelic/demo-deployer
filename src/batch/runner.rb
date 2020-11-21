require "fileutils"

require_relative "definitions/deployment"
require_relative "definitions/partition"

require "./src/common/tasks/process_task"


module Batch
  class Runner

    def initialize(context)
      @context = context
    end

    def deploy(partition)
      errors = execute(partition)
      unless errors.empty?
        raise errors.join("\n")
      end
    end

    def teardown(partition)
      is_teardown = true
      errors = execute(partition, is_teardown)
      unless errors.empty?
        if is_ignore_teardown_errors?()
          errors.each do |error|
            Common::Logger::LoggerFactory.get_logger().debug(error)
          end
        else
          raise errors.join("\n")
        end
      end
    end

    private
    def execute(partition, is_teardown = false)
      processes = []
      base_command = "ruby main.rb"
      execution_path = Dir.pwd
      
      partition.get_all_deployments().each do |deployment|
        command = base_command +" -c #{deployment.get_user_config_filepath()}" +" -d #{deployment.get_deploy_config_filepath()}"
        if is_teardown == true
          command += " -t"
        end
        process = Common::Tasks::ProcessTask.new(command, execution_path, "[ERROR]: Running 'deployer' for #{command} FAILED", deployment)
        lambda_on_start = lambda do |pid|
            Common::Logger::LoggerFactory.get_logger().debug("Running 'deployer' for deployment_name: #{deployment} with command: #{command} and execution_path: #{execution_path}, pid: #{pid}")
        end
        pid = process.start(lambda_on_start)
        processes.push(process)
      end

      errors = []
      processes.each do |process|
        process_output = process.wait_to_completion()
        exit_code = process_output.get_exit_code()
        deployment = process.get_context()
        succeeded = process_output.succeeded?()
        if succeeded == true
          Common::Logger::LoggerFactory.get_logger().debug("Running 'deployer' for deployment_name: #{deployment} SUCCEED in #{process.get_execution_time()}s with exit code:#{exit_code}")
        else
          message = "'deployer' for deployment_name: #{deployment} FAILED with exit_code:#{exit_code}, executed in #{process.get_execution_time()}s"
          errors.push("#{message} output:#{process_output.get_stdout()}")
        end
      end
      return errors.compact()

    end

    def is_ignore_teardown_errors?()
      return @context.get_command_line_provider().is_ignore_teardown_errors?()
    end

  end
end