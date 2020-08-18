module Common
  module Validators
    class DirectoryExistValidator

      def execute(path)
        if path.nil?
          return "Directory path is not defined"
        end
        if path.empty?
          return "Directory path is not defined"
        end
        begin
          unless File.directory?(path)
            return "Directory '#{path}' doesn't exist"
          end
        rescue Exception => ex
          return "Directory #{path} cannot be verified, #{ex.message}"
        end
        return nil
      end

    end
  end
end