require "./src/common/validators/validator"

module UserConfig
  module Validators
    class GitValidator

      def initialize(
        )
      end

      def execute(git_configs)
        validators = [
        ]

        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

    end
  end
end