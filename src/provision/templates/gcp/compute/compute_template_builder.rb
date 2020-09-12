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

          def build_template_contexts(deployment_name, services_provider, app_config_provider)
            template_contexts = []
            template_contexts.push(get_compute_template(deployment_name, services_provider))
            template_contexts.push(get_vnet_template(deployment_name, services_provider))
            return template_contexts
          end

          def build_output_contexts(deployment_name, services_provider, app_config_provider)
            output_contexts = []
            output_contexts.push(get_compute_template(deployment_name, services_provider))
            return output_contexts
          end

          private

          def get_compute_template(deployment_name, services_provider)
            @compute_template_context ||= ComputeTemplateContext.new(@output_dir_path, "#{@template_root_path}/compute", deployment_name, services_provider, @resource)
            return @compute_template_context
          end

          def get_vnet_template(deployment_name, services_provider)
            @vnet_template_context ||= Templates::Gcp::Vnet::VnetTemplateContext.new(@output_dir_path, @template_root_path, deployment_name, services_provider, @resource)
            return @vnet_template_context
          end

        end
      end
    end
  end
end