module UserAcceptanceTests
  module Spoofers
    class FileSpoofer

      def initialize(filename)
        @filename = filename
      end

      def dispose()
        if File.exists?(@filename)
          begin
            File.delete(@filename)
          rescue Exception => e
            raise StandardError("Failed to delete file: #{@filename}, reason: #{e}. Delete this file manually.")
          end
        end
      end

    end
  end
end