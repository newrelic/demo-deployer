module Common
  module Install
    module Templates
      class HostsTemplateContext

        def initialize(action_name, erb_input_path, yaml_output_path, provisioned_resource)
          @action_name = action_name
          @erb_input_path = erb_input_path
          @yaml_output_path = yaml_output_path
          @provisioned_resource = provisioned_resource
        end

        def get_template_input_file_path()
          return "#{@erb_input_path}/hosts_template.erb"
        end

        def get_template_output_file_path()
          return "#{@yaml_output_path}/hosts"
        end

        def get_id()
          return @provisioned_resource.get_id()
        end

        def host_exist?()
          if @provisioned_resource.get_ip() != nil
            return true
          else
            return false
          end
        end

        def get_template_binding()
          destination = {}

          destination[:action_name] = @action_name

          destination_remote_user = @provisioned_resource.get_user_name()
          destination[:remote_user] = destination_remote_user

          destination_ip = @provisioned_resource.get_ip()
          destination[:ip] = destination_ip

          if ['localhost','127.0.0.1', '0.0.0.0'].include?(destination_ip)
            destination[:force_local_connection] = 'ansible_connection=local'
          end

          template_binding = Kernel.binding()
          template_binding.local_variable_set('destination', destination)

          return template_binding
        end

      end
    end
  end
end