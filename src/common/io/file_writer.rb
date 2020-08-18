module Common
  module Io
    class FileWriter

      def initialize(full_path, contents)
        @full_path = full_path
        @contents = contents
      end

      def execute()
        begin
          file = File.open(@full_path, 'w')
          file.write(@contents)
        rescue IOError => ex
          raise Common::ValidationError.new("Failed to write file: #{@full_path}", [ex.message])
        ensure
          file.close unless file.nil?
        end        
      end
      
    end
  end
end

