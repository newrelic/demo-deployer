require "./src/common/type_repository"
require "./src/provision/templates/aws/template_factory"
require "./src/provision/templates/azure/template_factory"

module Provision
  class TemplateProvisionFactory

    def initialize(template_path, supported_types = nil, type_repository = nil)
      @template_path = template_path
      @supported_types = supported_types
      @type_repository = type_repository
    end

    def create(resource)
      repository = get_repository()
      type = repository.get(resource)
      return type.new(@template_path)
    end

    private
    def get_supported_types()
      @supported_types ||= {
        "aws" => Provision::Templates::Aws::TemplateFactory,
        "azure" => Provision::Templates::Azure::TemplateFactory
      }
    end

    def get_key_lookup_lambda()
      return lambda {|resource| return resource.get_provider()}
    end
    
    def get_repository()
      return @type_repository ||= Common::TypeRepository.new(get_supported_types(), get_key_lookup_lambda())
    end

  end
end
