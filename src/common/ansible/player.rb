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

      def execute( isAsync = true)
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
          pid = process.start(lambda_on_start)
          processes.push(process)
          unless isAsync
            process.wait_to_completion()
          end
        end

        errors = []
        processes.each do |process|
          processs_output = process.wait_to_completion()
          exit_code = processs_output.get_exit_code()
          succeeded = processs_output.succeeded?
          play = process.get_context()
          on_executed_handlers = play.get_on_executed_handlers()
          script_path = play.get_script_path()
          output_content = File.read(play.get_output_file_path())
          if output_content.length()>0
            if output_content.include?(" failed=0 ")
              if succeeded == false
                Common::Logger::LoggerFactory.get_logger().info("output has no failed for path #{script_path}, assuming success")
                succeeded = true
              end
            else
              if succeeded == true
                Common::Logger::LoggerFactory.get_logger().info("output has a number of failed that is not zero for path #{script_path}, assuming failure")
                succeeded = false
              end
            end
          end
          if succeeded == true
            (on_executed_handlers || []).each do |handler|
              handler.call()
            end
            Common::Logger::LoggerFactory.get_logger().debug("Running 'ansible-playbook' for #{play.get_script_path()} SUCCEED in #{process.get_execution_time()}s with exit code:#{exit_code}")
          else
            message = "#{script_path} exit_code:#{exit_code}, executed in #{process.get_execution_time()}s"
            errors.push("#{message} output:#{output_content}")
          end

        end
        return errors.compact()
      end
    end
  end
end
