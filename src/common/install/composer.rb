require './src/common/logger/logger_factory'
require './src/common/template_merger'
require './src/common/io/directory_service'

require './src/common/install/templates/hosts_template_context'
require './src/common/install/templates/ansible_template_context'
require './src/common/install/templates/action_template_context'

require './src/common/install/install_context'
module Common
module Install
  class Composer

    def initialize(directory_service, template_merger = nil)
      @directory_service = directory_service
      @template_merger = (template_merger || Common::TemplateMerger.new())
    end

    def execute(action_name, install_definitions = [])
      template_contexts = []
      install_contexts = []

      Common::Logger::LoggerFactory.get_logger().debug("Common::Install Composer execute(#{action_name}) definitions:#{install_definitions.length}")

      install_definitions.each do |install_definition|
        provisioned_resource = install_definition.get_provisioned_resource()
        service_id = install_definition.get_service_id()
        erb_input_path = install_definition.get_erb_input_path()
        yaml_output_path = install_definition.get_yaml_output_path()
        roles_path = install_definition.get_roles_path()
        action_vars = install_definition.get_action_vars()
        output_params = install_definition.get_output_params()
        base_role_path = roles_path.split(":")[0]
        action_directory_path = Common::Io::DirectoryService.combine_paths(
          base_role_path,
          action_name)

        Common::Logger::LoggerFactory.get_logger().debug("Composing for action_directory_path:#{action_directory_path}")

        if Dir.exist?(action_directory_path)
          action_path = Common::Io::DirectoryService.combine_paths(
            yaml_output_path,
            action_name)
          absolute_paths = @directory_service.get_subdirectory_paths(action_path)
          absolute_path = absolute_paths.last()
          if Dir.exist?(absolute_path)
            raise Common::InstallError.new("Cannot generate templates for action path #{absolute_path}, the directory already exists. Proceeding would overwrite the previously generated templates.")
          end
          absolute_yaml_output_path = @directory_service.create_sub_directory(action_path)
          Common::Logger::LoggerFactory.get_logger().debug("Creating templates for action path:#{absolute_yaml_output_path}")

          host_template_context = Common::Install::Templates::HostsTemplateContext.new(action_name, erb_input_path, absolute_yaml_output_path, provisioned_resource)
          template_contexts.push(host_template_context)

          ansible_template_context = Common::Install::Templates::AnsibleTemplateContext.new(erb_input_path, absolute_yaml_output_path, roles_path, get_key_path_lambda(provisioned_resource))
          template_contexts.push(ansible_template_context)

          action_context = Common::Install::Templates::ActionTemplateContext.new(action_name, erb_input_path, absolute_yaml_output_path, provisioned_resource, action_vars)
          template_contexts.push(action_context)

          install_context = Common::Install::InstallContext.new(service_id, absolute_yaml_output_path, action_context, host_template_context, output_params)
          install_contexts.push(install_context)

        else
          Common::Logger::LoggerFactory.get_logger().debug("Common::Install Composer execute() action_directory_path:#{action_directory_path} does not exist, skipping")
        end

      end

      merge_templates(template_contexts)

      return install_contexts
    end

    private
    def get_key_path_lambda(provisioned_resource)
      unless provisioned_resource.nil?
        return lambda { return provisioned_resource.get_credential().get_secret_key_path() }
      end
      return lambda { return nil }
    end

    def merge_templates(template_contexts)
      template_contexts.each do |template_context|
        @template_merger.merge_template_save_file(template_context)
      end
    end

  end
end
end
