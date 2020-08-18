module Common
  module Validators
    class NotNullOrEmptyValidator
      
      def initialize(error_message = nil)
        @error_message = error_message || "Null or Empty"
      end

      def execute(object)        
        if object.nil?
          return @error_message
        end
        if object.kind_of?(String) && object.empty?
          return @error_message
        end
        if object.kind_of?(Array) && object.empty?
          return @error_message
        end
        return nil
      end

    end
  end
end