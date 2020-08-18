module Common
  module Io
    class FileReader

      def initialize(filepath, error_msg = nil)
        @filepath = filepath
        @error_msg = error_msg
      end

      def execute()
        begin
          file = File.read(@filepath)
        rescue SystemCallError => ex
            raise Common::ValidationError.new(get_error_msg(), [ex.message])
        else
          return file          
        end      
      end

      def get_error_msg() 
        return @error_msg ||= "Unable to read: #{@filepath}: "         
      end
      
    end
  end
end

