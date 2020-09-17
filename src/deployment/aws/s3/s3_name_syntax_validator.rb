module Deployment
  module Aws
    module S3
      class S3NameSyntaxValidator
        
        def initialize(errorPrefix = nil)
          @errorPrefix = errorPrefix
        end

        def execute(string)
          if (string || "").match(/\A[a-z0-9.-]*\z/).nil?
            message = (@errorPrefix ||= "")
            if message.empty?
              message += " "
            end
            message += "bucket name \"#{string}\" can consist only of lowercase letters, numbers, dots (.), and hyphens (-)."
            return message
          end
          return nil
        end

      end
    end
  end
end