require "fileutils"
require "./src/common/tasks/process_task"
require './src/common/logger/logger_factory'

require_relative "play"

module Common
  module Ansible
    class Player
      def initialize()
        @plays = []
      end

      def stack(play)
        @plays.push(play)
      end

      def execute(isAsync = true)
        processes = []
        @plays.each do |play|
          script_path = play.get_script_path()
          host_file_path = play.get_host_file_path()
          execution_path = play.get_execution_path()
          output_file_path = "#{execution_path}/ansible.output"
          play.set_output_file_path(output_file_path)

          File.delete(output_file_path) if File.exist?(output_file_path)

          command = "ansible-playbook"
          if host_file_path != nil
            command += " -i #{host_file_path}"
          end

          if !play.host_exist?()
            command += " -c local"
          end

          if Common::Logger::LoggerFactory.get_logging_level() == 'debug'
            command += " -vvv"
          end

          command = "#{command} #{script_path}"
          command = "#{command} > #{output_file_path} 2>&1"
          process = Common::Tasks::ProcessTask.new(command, execution_path, "[ERROR]: Running 'ansible-playbook' for #{script_path} FAILED", play)
          lambda_on_start = lambda do |pid|
              Common::Logger::LoggerFactory.get_logger().debug("Running 'ansible-playbook' with command: #{command} and execution_path: #{execution_path}, pid: #{pid}")
          end

          lambda_on_end = lambda do |pid, exit_code, error_message|
            Common::Logger::LoggerFactory.get_logger().debug("Process 'ansible-playbook' completed exit_code: #{exit_code} error_message: #{error_message}")
            play.success()
          end

          pid = process.start(lambda_on_start, lambda_on_end)
          processes.push(process)

          unless isAsync
            process.wait_to_completion()
            play.success()
          end

        end

        errors = []
        processes.each do |process|
          process_output = process.wait_to_completion()
          exit_code = process_output.get_exit_code()
          play = process.get_context()
          on_executed_handlers = play.get_on_executed_handlers()
          script_path = play.get_script_path()
          output_content = File.read(play.get_output_file_path())
          succeeded = has_ansible_succeeded?(process_output.succeeded?, output_content, script_path)
          if succeeded == true
            (on_executed_handlers || []).each do |handler|
              handler.call()
            end
            Common::Logger::LoggerFactory.get_logger().debug("Running 'ansible-playbook' for #{play.get_script_path()} SUCCEED in #{process.get_execution_time()}s with exit code:#{exit_code}")
          else
            message = "#{script_path} exit_code:#{exit_code}, executed in #{process.get_execution_time()}s"
            errors.push("#{message} output:#{output_content}")
            play.error()
          end

        end
        return errors.compact()
      end

      def has_ansible_succeeded?(process_succeeded, output_content, script_path)
        if output_content.length()>0
          if / unreachable=[1-9]/.match(output_content)
            Common::Logger::LoggerFactory.get_logger().error("output has at least 1 unreachable status for path #{script_path}, assuming failure. Make sure the credential to access the resources are correct.")
            return false
          end

          if / failed=[1-9]/.match(output_content) && process_succeeded == true
            Common::Logger::LoggerFactory.get_logger().error("output has at least 1 failed status for path #{script_path}, assuming failure")
            return false
          end

          if / failed=0 /.match(output_content) && process_succeeded == false
            Common::Logger::LoggerFactory.get_logger().info("output has no failed for path #{script_path}, assuming success")
            return true
          end

        end
        return process_succeeded
      end
    end
  end
end
