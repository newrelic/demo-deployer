require_relative "r53ip_template_context"

module Provision
  module Templates
    module Aws
      module R53Ip
        class R53IpTemplateBuilder

          def initialize(resource, template_root_path, output_dir_path)
            @resource = resource
            @template_root_path = template_root_path
            @output_dir_path = output_dir_path
          end

          def build_template_contexts(context)
            template_contexts = []
            template_contexts.push(get_template(context))
            return template_contexts
          end

          def build_output_contexts(context)
            output_contexts = []
            output_contexts.push(get_template(context))
            return output_contexts
          end

          private

          def get_template(context)
            @template_context ||= R53IpTemplateContext.new(@output_dir_path, "#{@template_root_path}/r53ip", context, @resource)
            return @template_context
          end

        end
      end
    end
  end
end