require "fileutils"

require_relative "definitions/deployment"
require_relative "definitions/partition"

require "./src/common/tasks/process_task"

module Batch
  class Runner

    def initialize(context, process_launcher_lambda = nil)
      @context = context
      @process_launcher_lambda = process_launcher_lambda || lambda { |command, execution_path, error_message, deployment| return Common::Tasks::ProcessTask.new(command, execution_path, error_message, deployment) }
    end

    def deploy(partitions, on_complete_lambda = nil)
      all_errors = []
      on_complete_lambda = on_complete_lambda || lambda { |errors| return default_deploy_complete(errors) }
      partitions.each do |partition|
        log_token = Common::Logger::LoggerFactory.get_logger().task_start("Deploying:#{partition}")
        errors = single_deploy(partition)
        if errors.empty?
          log_token.success()
        else
          all_errors.concat(errors)
          log_token.error()
        end
      end

      on_complete_lambda.call(all_errors)
      return all_errors
    end

    def single_deploy(partition)
      return execute(partition)
    end

    def teardown(partitions, on_complete_lambda = nil)
      all_errors = []
      on_complete_lambda = on_complete_lambda || lambda { |errors| return default_teardown_complete(errors) }
      partitions.each do |partition|
        ignore_error_message = ""
        if is_ignore_teardown_errors?()
          ignore_error_message = " (ignore any errors)"
        end
        log_token = Common::Logger::LoggerFactory.get_logger().task_start("Tearing down:#{partition}#{ignore_error_message}")
        errors = single_teardown(partition)
        if errors.empty?
          log_token.success()
        else
          all_errors.concat(errors)
          log_token.error()
        end
      end

      on_complete_lambda.call(all_errors)
      return all_errors
    end

    def single_teardown(partition)
      is_teardown = true
      return execute(partition, is_teardown)
    end

    private
    def default_deploy_complete(errors)
      unless errors.empty?
        raise errors.join("\n")
      end
    end

    def default_teardown_complete(errors)
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

    def execute(partition, is_teardown = false)
      processes = []
      base_command = "ruby main.rb"
      execution_path = Dir.pwd

      partition.get_all_deployments().each do |deployment|
        command = base_command +" -c #{deployment.get_user_config_filepath()}" +" -d #{deployment.get_deploy_config_filepath()}" +" -l #{get_logging_level()}"
        if is_teardown == true
          command += " -t"
        end
        process = @process_launcher_lambda.call(command, execution_path, "[ERROR]: Running 'deployer' for #{command} FAILED", deployment)
        lambda_on_start = lambda do |pid|
            Common::Logger::LoggerFactory.get_logger().debug("Running 'deployer' for deployment_name: #{deployment} with command: #{command} and execution_path: #{execution_path}, pid: #{pid}")
        end
        pid = process.start(lambda_on_start)
        processes.push(process)
      end

      errors = []
      processes.each do |process|
        process_output = process.wait_to_completion()
        deployment = process.get_context()
        exit_code = process_output.get_exit_code()
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

    def get_logging_level()
      return @context.get_command_line_provider().get_logging_level()
    end

  end
end