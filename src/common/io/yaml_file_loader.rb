require "./src/common/validation_error"
require "yaml"

module Common
  module Io
    class YamlFileLoader

      def initialize(filepath, error_msg = nil)
        @filepath = filepath
        @error_msg = error_msg
      end

      def execute()
        begin
          file = YAML.load(File.read(@filepath))
        rescue Errno::ENOENT, Psych::SyntaxError => ex
          raise Common::ValidationError.new(get_error_msg(), [ex.message])
        end

        if file.nil?
          raise Common::ValidationError.new(get_error_msg(), ["Failed to parse YAML"])
        end

        return file
      end

      def get_error_msg()
        return @error_msg ||= "Unable to read: #{@filepath}: "
      end

    end
  end
end