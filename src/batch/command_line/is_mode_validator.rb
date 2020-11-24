module Batch
    module CommandLine
      class IsModeValidator

        def initialize(errorPrefix = "At least one mode is not valid.")
          @errorPrefix = errorPrefix
        end

        def execute(value)
          errors = []
          modes = split_or_input(value, ',')
          modes.each do |mode|
            valid = false
            case mode.downcase()
            when "deploy"
              valid = true
            when "teardown"
              valid = true
            end
            if valid == false
              errors.push("Got mode:#{mode}. Expecting one of: deploy, teardown")
            end
          end
          if errors.length>0
            return "#{@errorPrefix} #{errors.join(", ")}"
          end
          return nil
        end

        private
        def split_or_input(input, delimiter)
          unless input.nil? 
            if input.include?(delimiter)
              return input.split(delimiter)
            end
            return [input]
          end
          return []
        end

      end
    end
  end