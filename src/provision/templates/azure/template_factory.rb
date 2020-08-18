require "./src/common/type_repository"

require "./src/provision/templates/azure/vm/vm_template_builder"

module Provision
  module Templates
    module Azure
      class TemplateFactory

        def initialize(template_path, supported_types = nil, type_repository = nil)
          @supported_types = supported_types
          @type_repository = type_repository
          @template_root_path = template_path +"/azure"
        end

        def create(resource, deployment_name, directory_service)
          repository = get_repository()
          type = repository.get(resource)
          output_dir_path = get_output_dir_path(resource, deployment_name, directory_service)
          return type.new(resource, @template_root_path, output_dir_path)
        end

        private
        def get_output_dir_path(resource, deployment_name, directory_service)
          resource_id = resource.get_id()
          deployment_path = "#{deployment_name}/#{resource_id}"
          output_dir_path = directory_service.create_sub_directory(deployment_path)
          return output_dir_path
        end

        def get_key_lookup_lambda()
          return lambda {|resource| return resource.get_type()}
        end

        def get_repository()
          return @type_repository ||= Common::TypeRepository.new(get_supported(), get_key_lookup_lambda())
        end

        def get_supported()
          @supported_types ||= {
            "vm" => Provision::Templates::Azure::Vm::VmTemplateBuilder
          }
        end

      end
    end
  end
end