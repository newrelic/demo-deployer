require_relative 'process_output'
require 'benchmark'

module Common
  module Tasks
    class ProcessTask
      def initialize(command, execution_path, error_message = "[ERROR] command failed.", context = nil)
        @command = command
        @execution_path = execution_path
        @error_message = error_message
        @context = context
        @thread = nil
        @time = nil
        @processs_output = nil
      end

      def start(lambda_on_start = nil, lambda_on_end = nil)
        @thread ||= inner_start(lambda_on_start, lambda_on_end)
      end

      def wait_to_completion()
        start()
        # thread.value waits for the thread to complete
        @processs_output = @thread.value

        return @processs_output
      end

      def get_command()
        return @command
      end

      def get_context()
        return @context
      end

      def get_processs_output()
        return @processs_output
      end

      def get_execution_time()
        if @time != nil
          return @time.real
        end
        return nil
      end

      private
      def inner_start(lambda_on_start = nil, lambda_on_end = nil)
        thread = Thread.new{
          processs_output = nil
          @time = Benchmark.measure {
            processs_output = spawn_process(lambda_on_start, lambda_on_end)
          }
          processs_output
        }

        return thread
      end

      def spawn_process(lambda_on_start = nil, lambda_on_end = nil)
        rout, wout = IO.pipe
        rerr, werr = IO.pipe

        begin
          pid = Process.spawn(@command, :chdir=>@execution_path||"\tmp", :out => wout, :err => werr)

          unless lambda_on_start.nil?
            lambda_on_start.call(pid)
          end

          pid_found, process_exit_status = Process.wait2()

          exit_code = process_exit_status.exitstatus
          if exit_code != 0
            error_message = @error_message
          end
        rescue Errno::ENOENT => e
          exit_code = 255
          error_message = e.message
        ensure
          wout.close
          werr.close
          unless lambda_on_end.nil?
            lambda_on_end.call(pid, exit_code, error_message)
          end
        end

        stdout = rout.readlines.join("")
        stderr = rerr.readlines.join("")

        rout.close
        rerr.close

        processs_output = ProcessOutput.new(exit_code, stdout, stderr, error_message)
        return processs_output
      end

    end
  end
end