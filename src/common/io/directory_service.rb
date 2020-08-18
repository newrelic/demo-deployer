require 'fileutils'

require "./src/common/tasks/process_task"

module Common
  module Io
    class DirectoryService
      def initialize(root)
        @root = root.chomp("/")
      end

      def create_sub_directory(directory, as_new = false)
        final_directory = nil
        directory_paths = get_subdirectory_paths(directory)
        directory_paths.each do |directory_path|
          create(directory_path, as_new)
          final_directory = directory_path
        end
        return final_directory
      end

      def get_subdirectory_paths(directory)
        output = []
        basepath = @root
        directory = DirectoryService.remove_optional_leading_slash(directory)
        directory.split("/").each do |sub|
          basepath = "#{basepath}/#{sub}"
          output.push(basepath)
        end
        return output
      end

      def self.combine_paths(*paths)
        output = nil
        (paths || []).each do |path|
          if output.nil?
            output = path
          else
            path = DirectoryService.remove_optional_leading_slash(path)
            output = "#{output}/#{path}"
          end
        end
        return output
      end

      private
      def self.remove_optional_leading_slash(path)
        while path.index("/") == 0
          path = path.sub("/", "")
        end
        return path
      end

      def create(directory_path, as_new)        
        if as_new == true && File.exist?(directory_path)
          FileUtils.remove_dir(directory_path, true)
        end
        if File.exist?(directory_path) == false
          FileUtils.mkdir_p(directory_path)
        end
        command = "chmod 1755 #{directory_path}"
        process = Common::Tasks::ProcessTask.new(command, directory_path)
        process.wait_to_completion()
      end
    
    end
  end
end