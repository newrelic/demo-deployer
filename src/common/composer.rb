require "./src/common/template_merger"

module Common
  class Composer

    def initialize(directory_service, template_provision_factory, template_merger = nil)
      @directory_service = directory_service
      @template_provision_factory = template_provision_factory
      @template_merger = template_merger
    end

    def execute(context, resources)
      template_contexts = []
      output_contexts = []
      deployment_name = context.get_command_line_provider().get_deployment_name()

      resources.each do |resource|
        template_factory = @template_provision_factory.create(resource)
        factory = template_factory.create(resource, deployment_name, @directory_service)

        templates = factory.build_template_contexts(context)
        template_contexts.push(templates)

        outputs = factory.build_output_contexts(context)
        output_contexts.push(outputs)
      end

      merge_templates(template_contexts.flatten())
      return output_contexts.flatten()
    end

    private
    def merge_templates(template_contexts)
      template_contexts.each do |template_context|
        get_template_merger().merge_template_save_file(template_context)
      end
    end

    def get_template_merger()
      return @template_merger ||= Common::TemplateMerger.new()
    end

  end
end