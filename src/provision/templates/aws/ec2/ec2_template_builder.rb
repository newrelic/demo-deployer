require_relative "ec2_template_context"

require "./src/provision/templates/aws/vpc/vpc_template_context.rb"

module Provision
  module Templates
    module Aws
      module Ec2
        class Ec2TemplateBuilder

          def initialize(resource, template_root_path, output_dir_path)
            @resource = resource
            @template_root_path = template_root_path
            @output_dir_path = output_dir_path
          end

          def build_template_contexts(context)
            template_contexts = []
            template_contexts.push(get_ec2_template(context))
            template_contexts.push(get_vpc_template(context))
            return template_contexts
          end

          def build_output_contexts(context)
            output_contexts = []
            output_contexts.push(get_ec2_template(context))
            return output_contexts
          end

          private

          def get_ec2_template(context)
            @ec2_template_context ||= Ec2TemplateContext.new(@output_dir_path, "#{@template_root_path}/ec2", context, @resource)
            return @ec2_template_context
          end

          def get_vpc_template(context)
            @vpc_template_context ||= Provision::Templates::Aws::Vpc::VpcTemplateContext.new(@output_dir_path, @template_root_path, context, @resource)
            return @vpc_template_context
          end

        end
      end
    end
  end
end