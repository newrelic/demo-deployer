module UserAcceptanceTests
    class FileFinder

      def self.find_up(filename, path)
        if path.nil?
            return nil
        end
        while path.include?("user_acceptance_tests") && Dir.exist?(path)
            user_filepath = "#{path}/#{filename}"
            if File.exist?(user_filepath)
                return user_filepath
            end
            path = File.expand_path("..", path)
        end
        puts "File #{filename} was not found, last searched path was #{path}"
        return nil
      end

    end
end