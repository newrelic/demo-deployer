module Common
  module Tasks
    class ProcessOutput
      def initialize(exit_code, stdout, stderr, error_message)
        @exit_code = exit_code
        @stdout = stdout
        @stderr = stderr
        @error_message = error_message
      end

      def succeeded?(*valid_codes)
        if valid_codes.empty?
          valid_codes = [0]
        end
        return valid_codes.include?(@exit_code)
      end

      def get_exit_code()
        return @exit_code
      end

      def get_stdout()
        return @stdout
      end

      def get_stderr()
        return @stderr
      end

      def get_error_message()
        return @error_message
      end

    end
  end
end