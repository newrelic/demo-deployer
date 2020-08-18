require "fileutils"

module UserAcceptanceTests
  module Spoofers
    class DirectorySpoofer

      def initialize(filename)
        @filename = filename        
        @directory_path = __dir__
      end

      def dispose()
        filename = get_filename()
        if Dir.exists?(filename)
          begin
            FileUtils.remove_dir(filename)
          rescue Exception => e
            raise StandardError("Failed to delete directory: #{filename}, reason: #{e}. Delete this file manually.")
          end
        end
      end

      def get_filename()
        return "#{@directory_path}/#{@filename}"
      end

      def set_directory_path(path)
        @directory_path = path
      end

    end
  end
end