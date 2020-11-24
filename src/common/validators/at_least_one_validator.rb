module Common
    module Validators
      class AtLeastOneValidator
        def initialize(validators = [], error_prefix = "All validators failed")
            @validators = validators
            @error_prefix = error_prefix
        end

        def execute()
          errors = []
          @validators.each do |validator|
            begin
              result = validator.call()
              if result.nil?
                return []
              end
              if result.kind_of?(Array)
                errors.concat(result)
              else
                errors.push(result)
              end
            end
          end
          errors = errors.compact()
          return "#{@error_prefix}:#{errors.join(", ")}"
        end
      end
    end
  end