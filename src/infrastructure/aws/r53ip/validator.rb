require "./src/common/validators/not_null_or_empty_list_validator"

module Infrastructure
  module Aws
    module R53Ip
      class Validator

        def initialize(
          domain_exist_validator = Common::Validators::NotNullOrEmptyListValidator.new("domain", "The following resources have no domain defined:"),
          at_least_one_validator = Common::Validators::AtLeastOneNotNullOrEmptyValidator.new(["listeners", "reference_id"]),
          at_most_one_validator = Common::Validators::AtMostOneNotNullAndDefinedValidator.new(["listeners", "reference_id"])
  
        )
          @domain_exist_validator = domain_exist_validator
          @at_least_one_validator = at_least_one_validator
          @at_most_one_validator = at_most_one_validator
        end

        def execute(resources)
          validators = [
            lambda { return @domain_exist_validator.execute(resources) },
            lambda { return @at_least_one_validator.execute(resources) },
            lambda { return @at_most_one_validator.execute(resources) }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

      end

    end
  end
end