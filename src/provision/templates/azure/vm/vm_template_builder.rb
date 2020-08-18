require_relative "vm_template_context"
require "./src/provision/templates/azure/vnet/vnet_template_context.rb"

module Provision
  module Templates
    module Azure
      module Vm
        class VmTemplateBuilder

          def initialize(resource, template_root_path, output_dir_path)
            @resource = resource
            @template_root_path = template_root_path
            @output_dir_path = output_dir_path
          end

          def build_template_contexts(context)
            template_contexts = []
            template_contexts.push(get_vm_template(context))
            template_contexts.push(get_vnet_template(context))
            return template_contexts
          end

          def build_output_contexts(context)
            output_contexts = []
            output_contexts.push(get_vm_template(context))
            return output_contexts
          end

          private

          def get_vm_template(context)
            @vm_template_context ||= VmTemplateContext.new(@output_dir_path, "#{@template_root_path}/vm", context, @resource)
            return @vm_template_context
          end

          def get_vnet_template(context)
            @vnet_template_context ||= Templates::Azure::Vnet::VnetTemplateContext.new(@output_dir_path, @template_root_path, context, @resource)
            return @vnet_template_context
          end

        end
      end
    end
  end
end