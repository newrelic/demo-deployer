module Common
    module Validators
      class Validator
        def initialize(validators = [])
            @validators = validators
        end

        def execute()
          errors = []
          @validators.each do |validator|
            begin
              result = validator.call()
              if result.kind_of?(Array)
                errors.concat(result)
              else
                errors.push(result)
              end
            end
          end
          return errors.compact()
        end
      end
    end
  end