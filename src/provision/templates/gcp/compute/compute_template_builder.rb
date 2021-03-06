require_relative "compute_template_context"
require "./src/provision/templates/gcp/vnet/vnet_template_context.rb"

module Provision
  module Templates
    module Gcp
      module Compute
        class ComputeTemplateBuilder

          def initialize(resource, template_root_path, output_dir_path)
            @resource = resource
            @template_root_path = template_root_path
            @output_dir_path = output_dir_path
          end

          def build_template_contexts(context)
            template_contexts = []
            template_contexts.push(get_compute_template(context))
            template_contexts.push(get_vnet_template(context))
            return template_contexts
          end

          def build_output_contexts(context)
            output_contexts = []
            output_contexts.push(get_compute_template(context))
            return output_contexts
          end

          private

          def get_compute_template(context)
            @compute_template_context ||= ComputeTemplateContext.new(@output_dir_path, "#{@template_root_path}/compute", context, @resource)
            return @compute_template_context
          end

          def get_vnet_template(context)
            @vnet_template_context ||= Templates::Gcp::Vnet::VnetTemplateContext.new(@output_dir_path, @template_root_path, context, @resource)
            return @vnet_template_context
          end

        end
      end
    end
  end
end