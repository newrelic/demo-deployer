module Service
    module CommandLine
      class IsIntegerValidator

        def initialize(valid_integer_comparer_lambda, errorPrefix = "This is not a valid number:")
          @valid_integer_comparer_lambda = valid_integer_comparer_lambda
          @errorPrefix = errorPrefix
        end

        def execute(input)
          if @valid_integer_comparer_lambda.call(input) == false
            message = (@errorPrefix ||= "")
            if message.empty?
              message += " "
            end
            message += "#{input}"
            return message
          end
          return nil
        end

      end
    end
  end