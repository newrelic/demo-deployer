require_relative "s3_template_context"

module Provision
  module Templates
    module Aws
      module S3
        class S3TemplateBuilder

          def initialize(resource, template_root_path, output_dir_path)
            @resource = resource
            @template_root_path = template_root_path
            @output_dir_path = output_dir_path
          end

          def build_template_contexts(context)
            template_contexts = []
            template_contexts.push(get_s3_template(context))
            return template_contexts
          end

          def build_output_contexts(context)
            output_contexts = []
            output_contexts.push(get_s3_template(context))
            return output_contexts
          end

          private

          def get_s3_template(context)
            @s3_template_context ||= S3TemplateContext.new(@output_dir_path, "#{@template_root_path}/s3", context, @resource)
            return @s3_template_context
          end

        end
      end
    end
  end
end