module Infrastructure
  module Aws
    module Lambda
      class Validator

        def execute(resources)
          validator = Common::Validators::Validator.new()
          return validator.execute()
        end
        
      end
    end
  end
end