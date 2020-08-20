module UserAcceptanceTests
    class FileFinder

      def self.find_up(filename, path)
        if path.nil?
            return nil
        end
        while path.include?("user_acceptance_tests") && Dir.exist?(path)
            user_filepath = "#{path}/#{filename}"
            files = Dir["#{path}/#{filename}"]
            if files.length > 0
              return files[0]
            end
            path = File.expand_path("..", path)
        end
        puts "File #{filename} was not found, last searched path was #{path}"
        return nil
      end

    end
end