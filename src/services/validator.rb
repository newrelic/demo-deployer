require "json"

require "./src/common/validators/validator"
require "./src/common/validators/alpha_numeric_list_validator"
require "./src/common/validators/not_null_or_empty_validator"
require "./src/common/validators/not_null_or_empty_list_validator"
require "./src/common/validators/unique_id_validator"
require "./src/common/validators/field_exist_validator"
require "./src/common/validators/max_length_validator"

require_relative "port_validator"
require_relative "relationships_validator"
require_relative "source_validator"
require_relative "provider_credential_validator"
module Services
  class Validator

    def initialize(
        context,
        service_id_validator = Common::Validators::FieldExistValidator.new("id", "Service id is missing:"),
        unique_id_validator = Common::Validators::UniqueIdValidator.new("id", "Duplicate service_id found:"),
        deploy_script_path_validator = Common::Validators::FieldExistValidator.new("deploy_script_path", "deploy_script_path is missing, this is typically \"/deploy/linux/roles\" :"),
        port_validator = PortValidator.new(),
        destination_exist_validator = Common::Validators::NotNullOrEmptyListValidator.new("destinations", "The following services have no destination defined:"),
        relationships_validator = RelationshipsValidator.new("The following service relationships are not valid:"),
        service_id_length_validator = nil,
        source_validator = SourceValidator.new(),
        id_alphanumeric_validator = Common::Validators::AlphaNumericListValidator.new("id", "Service id syntax error:"),
        provider_credential_validator = ProviderCredentialValidator.new(context.get_user_config_provider(), "The following service has invalid provider credential: ")
    )
      @service_id_validator = service_id_validator
      @unique_id_validator = unique_id_validator
      @deploy_script_path_validator = deploy_script_path_validator
      @port_validator = port_validator
      @destination_exist_validator = destination_exist_validator
      @relationships_validator = relationships_validator
      @service_id_length_validator = service_id_length_validator
      @source_validator = source_validator
      @id_alphanumeric_validator = id_alphanumeric_validator
      @provider_credential_validator = provider_credential_validator
    end

    def execute(services, resources, app_config_provider)
      validators = [
          lambda { return @service_id_validator.execute(services) },
          lambda { return @unique_id_validator.execute(services) },
          lambda { return @deploy_script_path_validator.execute(services) },
          lambda { return @port_validator.execute(services) },
          lambda { return @destination_exist_validator.execute(services) },
          lambda { return @relationships_validator.execute(services, resources) },
          lambda { return get_service_id_length_validator(app_config_provider).execute(services) },
          lambda { return @source_validator.execute(services) },
          lambda { return @id_alphanumeric_validator.execute(services) } ,
          lambda { return @provider_credential_validator.execute(services) }
      ]
      validator = Common::Validators::Validator.new(validators)
      return validator.execute()
    end

    private
    def get_service_id_length_validator(app_config_provider)
      id_max_length = app_config_provider.get_service_id_max_length()
      return @service_id_length_validator ||= Common::Validators::MaxLengthValidator.new("id", id_max_length, "Service id should be #{id_max_length} characters at most")
    end

  end
end