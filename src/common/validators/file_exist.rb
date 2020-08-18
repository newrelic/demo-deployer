module Common
  module Validators
    class FileExist
      def initialize(error_message = nil)
        @error_message = error_message || "No file defined"
      end

      def execute(filepath)
        unless filepath.nil?
          file_exist = File.exist?(filepath)
          unless file_exist
            return "File '#{filepath}' doesn't exist"
          end
          begin
            content = File.read(filepath)
          rescue Exception => ex
            return "File #{filepath} cannot be read, #{ex.message}"
          end
        else
          return  @error_message
        end
        return nil
      end

    end
  end
end