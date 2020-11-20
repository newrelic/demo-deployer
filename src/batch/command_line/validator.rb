require "./src/common/validators/validator"

module Batch
  module CommandLine
    class Validator

      def initialize()
      end

      def execute(options)
        validators = [
        ]
        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

    end
  end
end