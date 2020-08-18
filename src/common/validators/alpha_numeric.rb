module Common
  module Validators
    class AlphaNumeric
      
      def initialize(errorPrefix = nil)
        @errorPrefix = errorPrefix
      end

      def execute(string)
        if (string || "").match(/\A[a-zA-Z0-9-]*\z/).nil?
          message = (@errorPrefix ||= "")
          if message.empty?
            message += " "
          end
          message += "string \"#{string}\" must be alpha numeric"
          return message
        end
        return nil
      end

    end
  end
end