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
      all_error_files = []
      on_complete_lambda = on_complete_lambda || lambda { |error_files| return default_teardown_complete(error_files) }
      partitions.each do |partition|
        ignore_error_message = ""
        if is_ignore_teardown_errors?()
          ignore_error_message = " (ignore any errors)"
        end
        log_token = Common::Logger::LoggerFactory.get_logger().task_start("Tearing down:#{partition}#{ignore_error_message}")
        error_files = single_teardown(partition)
        if error_files.empty?
          log_token.success()
        else
          all_error_files.concat(error_files)
          log_token.error()
        end
      end

      on_complete_lambda.call(all_error_files)
      return all_error_files
    end

    def single_teardown(partition)
      is_teardown = true
      return execute(partition, is_teardown)
    end

    def has_deployment_succeeded?(output_content)
      if output_content.length()>0 && /Deployment successful!/.match(output_content)
        return true
      end
      return false
    end

    private
    def default_deploy_complete(error_files)
      output_log_files(error_files, true)
      unless error_files.empty?
        exit!(1)
      end
    end

    def default_teardown_complete(error_files)
      if is_ignore_teardown_errors?()
        output_log_files(error_files, false)
      else
        default_deploy_complete(error_files)
      end
    end

    def output_log_files(error_files, is_error)
      error_files.each do |error_file|
        if File.exist?(error_file)
          error = File.read(error_file)
          if is_error
            Common::Logger::LoggerFactory.get_logger().error(error)
          else
            Common::Logger::LoggerFactory.get_logger().debug(error)
          end
        else
          Common::Logger::LoggerFactory.get_logger().error("Cannot read file #{error_file} to display error output")
        end
      end
    end

    def execute(partition, is_teardown = false)
      processes = []
      base_command = "ruby main.rb"
      execution_path = Dir.pwd

      if File.exist?("/tmp/deployer") == false
        FileUtils.mkdir_p("/tmp/deployer")
      end

      partition.get_all_deployments().each do |deployment|
        command = base_command +" -c #{deployment.get_user_config_filepath()}" +" -d #{deployment.get_deploy_config_filepath()}" +" -l #{get_logging_level()}"
        if is_teardown == true
          command += " -t"
        end
        output_file_path = get_deployment_output(deployment)
        if File.exist?(output_file_path)
          File.delete(output_file_path)
        end
        command += " > #{output_file_path} 2>&1"
        process = @process_launcher_lambda.call(command, execution_path, "[ERROR]: Running 'deployer' for #{command} FAILED", deployment)
        lambda_on_start = lambda do |pid|
            Common::Logger::LoggerFactory.get_logger().debug("Starting 'deployer' for deployment_name: #{deployment} with command: #{command} and execution_path: #{execution_path}, pid: #{pid}")
        end
        pid = process.start(lambda_on_start)
        processes.push(process)
      end

      error_files = []
      processes.each do |process|
        process_output = process.wait_to_completion()
        deployment = process.get_context()
        exit_code = process_output.get_exit_code()
        output = get_output(deployment)
        succeeded = has_deployment_succeeded?(output)
        if succeeded == true
          Common::Logger::LoggerFactory.get_logger().debug("'deployer' for deployment_name: #{deployment.get_deployment_name()} SUCCEED in #{process.get_execution_time()}s with exit code:#{exit_code}")
        else
          message = "'deployer' for deployment_name: #{deployment.get_deployment_name()} FAILED in #{process.get_execution_time()}s with exit_code:#{exit_code}"
          Common::Logger::LoggerFactory.get_logger().error(message)
          error_file = get_deployment_output(deployment)
          error_files.push(error_file)
        end
      end
      return error_files.compact()

    end

    def get_deployment_output(deployment)
      return "/tmp/deployer/#{deployment.get_deployment_name()}.output"
    end

    def get_output(deployment)
      output_file_path = get_deployment_output(deployment)
      if File.exist?(output_file_path)
        output = File.read(output_file_path)
        return output
      else
        Common::Logger::LoggerFactory.get_logger().error("Cannot read file #{output_file_path}")
      end
    end

    def is_ignore_teardown_errors?()
      return @context.get_command_line_provider().is_ignore_teardown_errors?()
    end

    def get_logging_level()
      return @context.get_command_line_provider().get_logging_level()
    end

  end
end