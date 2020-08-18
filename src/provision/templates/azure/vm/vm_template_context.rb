require "./src/provision/templates/template_context.rb"
require "./src/provision/templates/azure/vnet/vnet_template_context.rb"

module Provision
  module Templates
    module Azure
      module Vm

        class VmTemplateContext < TemplateContext

          def initialize(output_file_path, template_file_path, context, resource)
            super(output_file_path, template_file_path, context, resource)
          end

          def get_template_input_file_path()
            return "#{get_template_file_path()}/template.erb"
          end

          def get_template_output_file_path()
            return "#{get_output_file_path()}/vm.yml"
          end

          def get_template_binding()
            template_binding = Kernel.binding()

            Provision::Templates::Azure::Vnet::VnetTemplateContext.set_template_context(template_binding, get_context(), get_resource())

            vm_template_context = {}
            vm_template_context[:remote_user] = get_resource().get_user_name()
            vm_template_context[:artifact_file_path] = get_output_file_path()

            parse_infrastructure_resource(vm_template_context)
            parse_deployment(vm_template_context)

            template_binding.local_variable_set("vm", vm_template_context)

            return template_binding
          end

          private
          def parse_infrastructure_resource(vm_template_context)
            vm_template_context[:instance_size] = get_resource().get_size()
            vm_template_context[:resource_id] = get_resource().get_id()
            vm_template_context[:tags] = get_resource_tags().to_json()
          end

          def get_resource_tags()
            service_ids = get_services_provider().aggregate_value(get_resource().get_id()) { |service| service.get_id() }
            tags = get_resource().get_tags()
            tags[:Name] = get_resource_name()
            tags[:Services] = service_ids.join('-')
            return tags
          end

          def parse_deployment(vm_template_context)
            deployment_name = get_deployment_name()
            resource_id = get_resource_id()
            vm_template_context[:resource_name] = "#{deployment_name}-#{resource_id}"
            vm_template_context[:ip_name] = "#{deployment_name}-#{resource_id}-ip"
            vm_template_context[:nic_name] = "#{deployment_name}-#{resource_id}-nic"
          end

        end
      end
    end
  end
end