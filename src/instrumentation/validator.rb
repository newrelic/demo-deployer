require "./src/instrumentation/validators/ids_key_exist_validator"
require "./src/instrumentation/validators/credential_block_exists_validator"
require "./src/common/validators/at_least_one_not_null_or_empty_validator"
require "./src/common/validators/at_most_one_not_null_and_defined_validator"
require "./src/instrumentation/validators/resource_validators"
require "./src/instrumentation/validators/service_validators"
require "./src/common/validators/validator"
require "./src/common/logger/logger_factory"

module Instrumentation
  class Validator

    def initialize(context,
        id_validator = Common::Validators::FieldExistValidator.new("id", "id is missing"),
        resource_ids_validator = Common::Validators::FieldExistValidator.new("resource_ids", "resource_ids is missing"),
        service_ids_validator = Common::Validators::FieldExistValidator.new("service_ids", "service_ids is missing"),
        credential_block_exists_validator = nil,
        source_location_validator = Common::Validators::AtLeastOneNotNullOrEmptyValidator.new(["local_source_path", "source_repository"]),
        only_one_source_location_validator = Common::Validators::AtMostOneNotNullAndDefinedValidator.new(["local_source_path", "source_repository"]),
        deploy_script_path_validator = Common::Validators::FieldExistValidator.new("deploy_script_path", "deploy_script_path is missing, this is typically \"deploy/python/linux/roles\" :"),
        resource_validators = Instrumentation::Validators::ResourceValidators.new(),
        service_validators = Instrumentation::Validators::ServiceValidators.new(),
        unique_id_validator = Common::Validators::UniqueIdValidator.new("id", "Duplicate ids found:")
        )
      @context = context
      @id_validator = id_validator
      @resource_ids_validator = resource_ids_validator
      @service_ids_validator = service_ids_validator
      @credential_block_exists_validator = credential_block_exists_validator || Instrumentation::Validators::CredentialBlockExistsValidator.new(get_user_config_provider())
      @source_location_validator = source_location_validator
      @only_one_source_location_validator = only_one_source_location_validator
      @deploy_script_path_validator = deploy_script_path_validator
      @resource_validators = resource_validators
      @service_validators = service_validators
      @unique_id_validator = unique_id_validator
    end

    def execute(parsed_instrumentors, resource_ids, service_ids)
      validators = []

      resource_instrumentors = get_instrumentors(parsed_instrumentors, "resources")
      parsed_resource_ids = get_instrumentor_item_ids(resource_instrumentors, "resource_ids")
      validators.push(lambda { return @resource_ids_validator.execute(resource_instrumentors) })
      validators.push(lambda { return @unique_id_validator.execute(resource_instrumentors) })
      validators.push(get_validators(resource_instrumentors, @resource_validators, parsed_resource_ids, resource_ids))

      service_instrumentors = get_instrumentors(parsed_instrumentors, "services")
      parsed_service_ids = get_instrumentor_item_ids(service_instrumentors, "service_ids")
      validators.push(lambda { return @service_ids_validator.execute(service_instrumentors) })
      validators.push(lambda { return @unique_id_validator.execute(service_instrumentors) })
      validators.push(get_validators(service_instrumentors, @service_validators, parsed_service_ids, service_ids))

      validators = validators.flatten()
      validator = Common::Validators::Validator.new(validators)
      return validator.execute()
    end

    private
    def get_validators(parsed_instrumentor, item_validator, parsed_ids, ids)
      validators = [
        lambda { return @id_validator.execute(parsed_instrumentor) },
        lambda { return @credential_block_exists_validator.execute(parsed_instrumentor) },
        lambda { return @source_location_validator.execute(parsed_instrumentor) },
        lambda { return @only_one_source_location_validator.execute(parsed_instrumentor) },
        lambda { return @deploy_script_path_validator.execute(parsed_instrumentor) },
        lambda { return item_validator.execute(parsed_ids, ids) }
      ]
      return validators
    end

    def get_user_config_provider()
      return @user_config_provider ||= @context.get_user_config_provider()
    end

    def get_instrumentors(parsed_instrumentors, key)
      instrumentors = []
      if parsed_instrumentors.key?(key)
        parsed_instrumentors[key].each do |parsed_instrumentor|
          unless parsed_instrumentor.nil?
            instrumentors.push(parsed_instrumentor)
          end
        end
      end
      if instrumentors.any?
        Common::Logger::LoggerFactory.get_logger().debug("Got instrumentors:#{instrumentors}")
      end

      return instrumentors
    end

    def get_instrumentor_item_ids(parsed_instrumentors, enum_key)
      item_ids = []
      parsed_instrumentors.each do |parsed_instrumentor|
        if parsed_instrumentor.key?(enum_key)
          parsed_instrumentor[enum_key].each do |id|
            item_ids.push(id)
          end
        end
      end
      return item_ids
    end

  end
end
