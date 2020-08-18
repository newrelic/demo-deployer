require "./src/common/validators/at_least_one_not_null_or_empty_validator"
require "./src/common/validators/at_most_one_not_null_and_defined_validator"
require "./src/services/supported_source_repository_validator"

module Services
  class SourceValidator

    def initialize(
      at_least_one_not_null_or_empty_validator = Common::Validators::AtLeastOneNotNullOrEmptyValidator.new(["local_source_path", "source_repository"]),
      at_most_one_not_null_and_defined_validator = Common::Validators::AtMostOneNotNullAndDefinedValidator.new(["local_source_path", "source_repository"]),
      supported_source_repository_validator = Services::SupportedSourceRepositoryValidator.new([".git"], "The following services source repository is not supported")
      )
      @at_least_one_not_null_or_empty_validator = at_least_one_not_null_or_empty_validator
      @at_most_one_not_null_and_defined_validator = at_most_one_not_null_and_defined_validator
      @supported_source_repository_validator = supported_source_repository_validator
    end

    def execute(services)
      validators = [
        lambda { return @at_least_one_not_null_or_empty_validator.execute(services) },
        lambda { return @at_most_one_not_null_and_defined_validator.execute(services) },
        lambda { return @supported_source_repository_validator.execute(services) }
      ]
      
      validator = Common::Validators::Validator.new(validators)
      return validator.execute()
    end
  end
end