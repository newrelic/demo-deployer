require "./user_acceptance_tests/spoofers/directory_spoofer"

module UserAcceptanceTests
  module Spoofers
    class DeploymentDirectorySpoofer < DirectorySpoofer

      def initialize(user_filename, deploy_filename)
        filename = strip_to_name(user_filename) +"-" +strip_to_name(deploy_filename)
        super(filename)
      end

      def strip_to_name(filepath)
        filename = File.basename(filepath)
        split = filename.split('.').first
        return split
      end

      def dispose()
        super()
      end

    end
  end
end