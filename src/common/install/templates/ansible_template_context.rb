module Common
  module Install
    module Templates
      class AnsibleTemplateContext

        def initialize(erb_input_path, yaml_output_path, roles_path, key_path_lambda)
          @erb_input_path = erb_input_path
          @yaml_output_path = yaml_output_path
          @roles_path = roles_path
          @key_path_lambda = key_path_lambda
        end

        def get_template_input_file_path()
          return "#{@erb_input_path}/ansible_template.erb"
        end

        def get_template_output_file_path()
          return "#{@yaml_output_path}/ansible.cfg"
        end

        def get_template_binding()
          key = {}

          key_path = @key_path_lambda.call()
          unless key_path.nil?
            key[:secret_file_path] = File.absolute_path(key_path)
          end

          template = {}
          template[:path] = @roles_path

          template_binding = Kernel.binding()
          template_binding.local_variable_set('key', key)
          template_binding.local_variable_set('template', template)

          return template_binding
        end

      end
    end
  end
end