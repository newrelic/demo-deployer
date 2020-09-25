require_relative "ansible_validator"
require_relative "service_host_exist_validator"
require_relative "listeners_exist_validator"
require_relative "listeners_validator"
require_relative "listeners_all_on_same_port_validator"
require_relative "service_resource_same_type_validator"
require './src/infrastructure/definitions/aws/elb_resource'
require './src/infrastructure/definitions/aws/r53ip_resource'
require "./src/common/validators/directory_exist_list_validator"
require "./src/common/validators/validator"
require "./src/common/validators/alpha_numeric"
require "./src/common/validators/json_file_exist"

require_relative "provider_validator_factory"

module Deployment
  class Validator

    def initialize(
        service_host_exist_validator = ServiceHostExistValidator.new(),
        username_validator = Common::Validators::AlphaNumeric.new("User configuration file name:"),
        deployname_validator = Common::Validators::AlphaNumeric.new("Deploy configuration file name:"),
        ansible_validator = AnsibleValidator.new(),
        elb_listeners_value_exist_in_services_validator = ListenersExistValidator.new(Infrastructure::Definitions::Aws::ElbResource),
        r53ip_listeners_value_exist_in_services_validator = ListenersExistValidator.new(Infrastructure::Definitions::Aws::R53IpResource),
        elb_dependency_on_listener_validator = ListenersValidator.new(Infrastructure::Definitions::Aws::ElbResource),
        elb_listeners_same_port_validator = ListenersAllOnSamePortValidator.new(Infrastructure::Definitions::Aws::ElbResource),
        r53ip_listeners_same_port_validator = ListenersAllOnSamePortValidator.new(Infrastructure::Definitions::Aws::R53IpResource),
        service_source_path_exist_validator = Common::Validators::DirectoryExistListValidator.new(lambda { |service| return service.get_source_path() }, "The source path for the following services do not exist:"),
        service_deploy_script_path_exist_validator = Common::Validators::DirectoryExistListValidator.new(lambda { |service| return service.get_deploy_script_full_path() }, "The deploy script path for the following services do not exist, this should typically be a path ending with \"/deploy/linux/roles\" :"),
        instrumentor_source_path_exist_validator = Common::Validators::DirectoryExistListValidator.new(lambda { |instrumentor| return instrumentor.get_source_path() }, "The source path for the following instrumentations do not exist:"),
        instrumentor_deploy_script_path_exist_validator = Common::Validators::DirectoryExistListValidator.new(lambda { |instrumentor| return instrumentor.get_deploy_script_full_path() }, "The deploy script path for the following instrumentations do not exist, this should typically be a path ending with \"/deploy/linux/roles\" :"),
        service_resource_same_type_validator = ServiceResourceSameTypeValidator.new("Those services are using resources of different types:"),
        provider_validator_factory = nil,
        deploy_config_validator = Common::Validators::JsonFileExist.new("No deploy config file defined"),
        service_instrumentor_item_validator = InstrumentorItemExistValidator.new("Those service instrumentors are missing an `item_id` service field:"),
        resource_instrumentor_item_validator = InstrumentorItemExistValidator.new("Those resource instrumentors are missing an `item_id` resource field:")
      )
      @service_host_exist_validator = service_host_exist_validator
      @username_validator = username_validator
      @deployname_validator = deployname_validator
      @ansible_validator = ansible_validator
      @elb_listeners_value_exist_in_services_validator = elb_listeners_value_exist_in_services_validator
      @r53ip_listeners_value_exist_in_services_validator = r53ip_listeners_value_exist_in_services_validator
      @elb_dependency_on_listener_validator = elb_dependency_on_listener_validator
      @elb_listeners_same_port_validator = elb_listeners_same_port_validator
      @r53ip_listeners_same_port_validator = r53ip_listeners_same_port_validator
      @service_source_path_exist_validator = service_source_path_exist_validator
      @service_deploy_script_path_exist_validator = service_deploy_script_path_exist_validator
      @instrumentor_source_path_exist_validator = instrumentor_source_path_exist_validator
      @instrumentor_deploy_script_path_exist_validator = instrumentor_deploy_script_path_exist_validator
      @service_resource_same_type_validator = service_resource_same_type_validator
      @provider_validator_factory = provider_validator_factory
      @deploy_config_validator = deploy_config_validator
      @service_instrumentor_item_validator = service_instrumentor_item_validator
      @resource_instrumentor_item_validator = resource_instrumentor_item_validator
    end

    def execute(context)
      command_line_provider = context.get_command_line_provider()
      infrastructure_provider = context.get_infrastructure_provider()
      instrumentation_provider = context.get_instrumentation_provider()
      services_provider = context.get_services_provider()
      app_config_provider = context.get_app_config_provider()
      username = command_line_provider.get_user_config_name()
      deployname = command_line_provider.get_deploy_config_name()
      deploy_filepath = command_line_provider.get_deploy_config_filepath()
      execution_path = app_config_provider.get_execution_path()
      resources = infrastructure_provider.get_all()
      resource_ids = infrastructure_provider.get_all_resource_ids()
      provider_names = infrastructure_provider.get_provider_names()
      instrumentors = instrumentation_provider.get_all()
      resource_instrumentors = instrumentation_provider.get_all_resource_instrumentors()
      service_instrumentors = instrumentation_provider.get_all_service_instrumentors()
      services = services_provider.get_services()

      validators = [
        lambda { return @service_host_exist_validator.execute(services, resource_ids) },
        lambda { return @username_validator.execute(username) },
        lambda { return @deployname_validator.execute(deployname) },
        lambda { return @ansible_validator.execute(execution_path) },
        lambda { return @elb_listeners_value_exist_in_services_validator.execute(resources, services) },
        lambda { return @r53ip_listeners_value_exist_in_services_validator.execute(resources, services) },
        lambda { return @elb_dependency_on_listener_validator.execute(resources) },
        lambda { return @elb_listeners_same_port_validator.execute(resources, services) },
        lambda { return @r53ip_listeners_same_port_validator.execute(resources, services) },
        lambda { return @service_source_path_exist_validator.execute(services) },
        lambda { return @service_deploy_script_path_exist_validator.execute(services) },
        lambda { return @instrumentor_source_path_exist_validator.execute(instrumentors) },
        lambda { return @instrumentor_deploy_script_path_exist_validator.execute(instrumentors) },
        lambda { return @service_resource_same_type_validator.execute(resources, services) },
        lambda { return @deploy_config_validator.execute(deploy_filepath) },
        lambda { return @service_instrumentor_item_validator.execute(service_instrumentors) },
        lambda { return @resource_instrumentor_item_validator.execute(resource_instrumentors) }
      ]

      provider_validators = get_provider_validators(resources, services, context)
      if provider_validators.size() > 0
        validators.concat(provider_validators)
      end

      validator = Common::Validators::Validator.new(validators)

      return validator.execute()
    end

    private
    def get_provider_validators(resources, services, context)
      return get_provider_validator_factory(services, context).create_validators(resources)
    end

    def get_provider_validator_factory(services, context)
      return @provider_validator_factory || ProviderValidatorFactory.new(services, context)
    end

  end
end