require "./src/common/validators/alpha_numeric_list_validator"
require "./src/common/validators/unique_id_validator"
require "./src/common/validators/field_exist_validator"
require "./src/common/validators/not_null_or_empty_validator"
require "./src/common/validators/max_length_validator"
require_relative "provider_validator_factory"

module Infrastructure
  class Validator

    def initialize(
        context,
        resource_id_validator = Common::Validators::FieldExistValidator.new("id", "Resource id is missing:"),
        unique_id_validator = Common::Validators::UniqueIdValidator.new("id", "Duplicate resource_id found:"),
        provider_validator_factory = nil,
        id_alphanumeric_validator = Common::Validators::AlphaNumericListValidator.new("id", "Resource id syntax error:")
        )
      @context = context
      @resource_id_validator = resource_id_validator
      @unique_id_validator = unique_id_validator
      @provider_validator_factory = provider_validator_factory
      @id_alphanumeric_validator = id_alphanumeric_validator
    end

    def execute(resources)
      validators = [
        lambda { return @resource_id_validator.execute(resources) },
        lambda { return @unique_id_validator.execute(resources) },
        lambda { return get_resource_id_length_validator().execute(resources) },
        lambda { return @id_alphanumeric_validator.execute(resources) }
      ]

      lambdas = get_provider_validators(resources)
      validators.concat(lambdas)

      validator = Common::Validators::Validator.new(validators)
      return validator.execute()
    end

    private
    def get_provider_validators(resources)
      return get_provider_validator_factory().create_validators(resources)
    end

    def get_resource_id_length_validator()
      id_max_length = get_resource_id_max_length()
      return @resource_id_length_validator ||= Common::Validators::MaxLengthValidator.new("id", id_max_length, "Resource id should be #{id_max_length} characters at most")
    end

    def get_provider_validator_factory()
      return @provider_validator_factory ||= ProviderValidatorFactory.new(@context)
    end

    def get_resource_id_max_length()
      app_config_provider = @context.get_app_config_provider()
      return app_config_provider.get_resource_id_max_length()
    end

  end
end
