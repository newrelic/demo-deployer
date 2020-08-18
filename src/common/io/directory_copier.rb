require "fileutils"
require "./src/common/logger/logger_factory"

module Common
  module Io
    class DirectoryCopier
      def copy(src, dest)
        if File.exist?(dest) == false
          FileUtils.mkdir_p(dest)
        end

        full_destination_path = get_full_destination_path(src, dest)
        Common::Logger::LoggerFactory.get_logger.debug("Copying #{src} to #{full_destination_path}")
        FileUtils.cp_r(src, dest)
        return full_destination_path
      end

      private

      def get_full_destination_path(src, dest)
        source_dir_name = File.basename(src)
        path = "#{dest}/#{source_dir_name}"
        return path
      end
    end
  end
end
