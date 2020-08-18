module Common
  module Validators
    class ErrorValidator
      
      def initialize(error)
        @error = error
      end

      def execute(*parameters)
        return @error
      end

    end
  end
end