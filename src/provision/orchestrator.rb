require "./src/common/io/directory_service"
require "./src/common/composer"

require "./src/provision/provisioner"
require "./src/provision/provider"
require "./src/provision/template_provision_factory"
require "./src/infrastructure/definitions/aws/aws_resource"
require "./src/common/logger/logger_factory"
require "./src/provision/actions/pre/orchestrator"


module Provision
  class Orchestrator

    def initialize(context,
                   temporary_directory_service = nil,
                   provisioner = nil,
                   composer = nil,
                   pre_actions_orchestrator = nil)
      @context = context
      @temporary_directory_service = temporary_directory_service
      @provisioner = (provisioner || Provision::Provisioner.new())
      @composer = composer
      @pre_actions_orchestrator = pre_actions_orchestrator
    end

    def execute(is_provisioning_enabled = true)
      log_token = Common::Logger::LoggerFactory.get_logger().task_start("Provisioner")
      @provisioner.set_info_logger_token(log_token)
      provider = Provision::Provider.new(get_infrastructure_provider())
      @context.set_provision_provider(provider)
      deployment_name = get_command_line_provider().get_deployment_name()
      get_temporary_directory_service().create_sub_directory(deployment_name)
      get_pre_actions_orchestrator().execute()

      provision_resources_by_group = get_infrastructure_provider().partition_by_provision_group()
      provision_resources_by_group.each do |resources|
        template_contexts = get_composer(is_provisioning_enabled).execute(@context, resources)
        @provisioner.execute(template_contexts, false)
      end

      log_token.success()
      return provider
    end

    private
    def get_temporary_directory_service()
      return (@temporary_directory_service ||= Common::Io::DirectoryService.new(get_execution_path()))
    end

    def get_command_line_provider()
      return (@command_line_provider ||= @context.get_command_line_provider())
    end

    def get_infrastructure_provider()
      return (@infrastructure_provider ||= @context.get_infrastructure_provider())
    end

    def get_template_provision_factory(is_provisioning_enabled)
      template_path = "./src/provision/templates"
      if (is_provisioning_enabled == false)
        template_path = "./src/provision/lookup_templates"
      end
      return Provision::TemplateProvisionFactory.new(template_path)
    end

    def get_composer(is_provisioning_enabled)
      if @composer.nil?
        return Common::Composer.new(get_temporary_directory_service(), get_template_provision_factory(is_provisioning_enabled))
      end
      return @composer
    end

    def get_execution_path()
      app_config_provider = @context.get_app_config_provider()
      execution_path = app_config_provider.get_execution_path()
      return execution_path
    end

    def get_pre_actions_orchestrator()
      return (@pre_actions_orchestrator ||= Provision::Actions::Pre::Orchestrator.new(@context))
    end

  end
end
