require "securerandom"
require "json"

require "./user_acceptance_tests/spoofers/file_spoofer"

module UserAcceptanceTests
    class JsonFileBuilder < UserAcceptanceTests::Spoofers::FileSpoofer

      def self.create_filename(path = nil)
        return "#{path || "."}/file#{SecureRandom.uuid().gsub(/[-]/, '')}.json"
      end

      def initialize(filename = nil)
        @filename = (filename || create_filename())
        super(@filename)
        @content = { }
      end

      def get_filename()
        return @filename
      end

      def with(key, value)
        @content[key.to_s] ||= value
      end

      def build()
        return @context ||= createInstance()
      end

      private
      def createInstance()          
        File.write(@filename, JSON.generate(@content))
        return @filename
      end

    end
end