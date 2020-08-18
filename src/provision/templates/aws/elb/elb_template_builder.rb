require_relative "elb_template_context"

module Provision
  module Templates
    module Aws
      module Elb
        class ElbTemplateBuilder

          def initialize(resource, template_root_path, output_dir_path)
            @resource = resource
            @template_root_path = template_root_path
            @output_dir_path = output_dir_path
          end

          def build_template_contexts(context)
            template_contexts = []
            template_contexts.push(get_elb_template(context))
            return template_contexts
          end

          def build_output_contexts(context)
            output_contexts = []
            output_contexts.push(get_elb_template(context))
            return output_contexts
          end

          private

          def get_elb_template(context)
            @elb_template_context ||= ElbTemplateContext.new(@output_dir_path, "#{@template_root_path}/elb", context, @resource)
            return @elb_template_context
          end

        end
      end
    end
  end
end