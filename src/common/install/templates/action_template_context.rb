module Common
  module Install
    module Templates
      class ActionTemplateContext

        def initialize(action_name, erb_input_path, yaml_output_path, provisioned_resource, action_vars)
          @action_name = action_name
          @erb_input_path = erb_input_path
          @yaml_output_path = yaml_output_path
          @provisioned_resource = provisioned_resource
          @action_vars = action_vars
        end

        def get_template_input_file_path()
          return "#{@erb_input_path}/action_template.erb"
        end

        def get_template_output_file_path()
          return "#{@yaml_output_path}/#{@action_name}.yml"
        end

        def get_execution_path()
          return "#{@yaml_output_path}"
        end

        def get_template_binding()
          template_binding = Kernel.binding()

          template_binding.local_variable_set('output_path', get_execution_path())
          template_binding.local_variable_set('action_name', @action_name)
          template_binding.local_variable_set('action_vars', @action_vars)
          params = {}
          unless @provisioned_resource.nil?
            @provisioned_resource.get_params().get_all()
          end
          template_binding.local_variable_set('params', params)
          return template_binding
        end

      end
    end
  end
end