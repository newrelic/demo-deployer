require "json"
require_relative "file_exist"

module Common
  module Validators
    class JsonFileExist < FileExist
      def initialize(error_message = nil)
        super(error_message)
      end

      def execute(filepath)
        error = super(filepath)
        unless error.nil?
          return error
        end
        begin
          content = File.read(filepath)
          JSON.parse(content)
        rescue Exception => ex
          return "File \"#{filepath}\" is not a valid json, #{ex.message}"
        end

        return nil
      end
      
    end
  end
end