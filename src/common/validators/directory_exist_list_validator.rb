require 'json'

require_relative "directory_exist_validator"

module Common
  module Validators
    class DirectoryExistListValidator
      
      def initialize(
        filepath_lambda,
        error_message = nil,
        directory_exist_validator = DirectoryExistValidator.new()
        )
        @filepath_lambda = filepath_lambda
        @error_message = error_message || "Null or Empty"
        @directory_exist_validator = directory_exist_validator
      end

      def execute(items)
        missing = []

        (items || []).each do |item|
          value = @filepath_lambda.call(item)
          error = @directory_exist_validator.execute(value)
          unless error.nil?
            missing.push(JSON.generate(item))
          end
        end
        
        if missing.length>0
          return "#{@error_message} #{missing.join(", ")}"
        end
  
        return nil
      end

    end
  end
end