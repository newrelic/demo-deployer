module Batch
    module CommandLine
      class IsModeValidator

        def initialize(errorPrefix = "This is not a valid mode:")
          @errorPrefix = errorPrefix
        end

        def execute(mode)
          valid = false
          case mode.downcase()
          when "deploy"
            valid = true
          when "teardown"
            valid = true
          when "deployteardown"
            valid = true
          end
          if valid == false
            return "mode is not valid, got #{mode}. Expecting one of: deploy, teardown or deployteardown"
          end
          return nil
        end

      end
    end
  end