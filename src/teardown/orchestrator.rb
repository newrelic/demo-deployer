require "./src/common/install_error"
require "./src/common/composer"

require "./src/teardown/uninstall_orchestrator"
require "./src/teardown/terminator"
require "./src/teardown/summary"
require "./src/provision/template_provision_factory"
require "./src/teardown/actions/post/orchestrator"
require './src/provision/orchestrator'

require "./src/common/logger/logger_factory"

module Teardown
  class Orchestrator

    def initialize(
        context,
        temporary_directory_service = nil,
        composer = nil,
        terminator = nil,
        summary = nil,
        post_actions_orchestrator = nil,
        provision_orchestrator = nil,
        uninstall_orchestrator = nil
      )
      @context = context
      @temporary_directory_service = temporary_directory_service
      @composer = composer
      @terminator = terminator
      @summary = summary
      @post_actions_orchestrator = post_actions_orchestrator
      @provision_orchestrator = provision_orchestrator
      @uninstall_orchestrator = uninstall_orchestrator
    end

    def execute()
      execute_provisioner()
      log_token = Common::Logger::LoggerFactory.get_logger().task_start("Terminating infrastructure")

      target_provisioned_resources = get_resources_target()
      Common::Logger::LoggerFactory.get_logger().debug("Uninstalling on #{target_provisioned_resources.length} resources")
      provisioned_resources_by_group = partition_by_provision_group_descending(target_provisioned_resources)
      if provisioned_resources_by_group.any?
        provisioned_resources_by_group.each do |provisioned_resources|
          get_uninstall_orchestrator().execute(provisioned_resources)
          errors = execute_teardown(provisioned_resources)
          if errors.length > 0
            log_token.error()
            raise Common::InstallError.new("Teardown resources has failed", errors)
          end
        end
      else
        get_uninstall_orchestrator().execute([])
      end
      get_post_actions_orchestrator().execute()

      log_token.success()
      get_summary().execute()
    end

    private

    def partition_by_provision_group_descending(provisioned_resources)
      grouped = provisioned_resources.group_by { |provisioned_resource| -1*provisioned_resource.get_resource().get_provision_group() }
      sorted = grouped.sort().to_h()
      return sorted.values()
    end

    def execute_teardown(provisioned_resources)
      resources = provisioned_resources.map { |provisioned_resource| provisioned_resource.get_resource() }
      composed_contexts = get_composer().execute(@context, resources)
      return get_terminator().execute(composed_contexts, false)
    end

    def execute_provisioner()
      is_provisioning_enabled = false
      provision_provider = get_provision_orchestrator().execute(is_provisioning_enabled)
      @context.set_provision_provider(provision_provider)
    end

    def get_resources_target()
      resources = @context.get_provision_provider().get_all()
      provisioned_resources = resources.find_all {|item| item.is_provisioned?()}
      return provisioned_resources
    end

    def get_template_teardown_factory()
      return Provision::TemplateProvisionFactory.new("./src/teardown/templates")
    end

    def get_composer()
      return @composer ||= Common::Composer.new(get_temporary_directory_service(), get_template_teardown_factory())
    end

    def get_terminator()
      return @terminator ||= Teardown::Terminator.new()
    end

    def get_summary()
      return @summary ||= Teardown::Summary.new()
    end

    def get_provision_orchestrator()
      return @provision_orchestrator ||= Provision::Orchestrator.new(@context)
    end

    def get_uninstall_orchestrator()
      return @uninstall_orchestrator ||= Teardown::UninstallOrchestrator.new(@context)
    end

    def get_execution_path()
      app_config_provider = @context.get_app_config_provider()
      execution_path = app_config_provider.get_execution_path()
      return execution_path
    end

    def get_temporary_directory_service()
      return (@temporary_directory_service ||= Common::Io::DirectoryService.new(get_execution_path()))
    end

    def get_post_actions_orchestrator()
      return (@post_actions_orchestrator ||= Teardown::Actions::Post::Orchestrator.new(@context))
    end

  end
end