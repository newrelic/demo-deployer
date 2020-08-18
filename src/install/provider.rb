require "./src/install/definitions/installed_service"

module Install
  class Provider

    def initialize(context)
      @context = context
      @installed_services = nil
    end

    def get_all()
      return @installed_services ||= create_installed_services()
    end

    def get_by_id(service_id)
      get_all().each do |installed_service|
        if installed_service.match_by_id(service_id)
          return installed_service
        end
      end
      return nil
    end

    private

    def create_installed_services()
      elements = []
      provision_provider = @context.get_provision_provider()
      services = @context.get_services_provider().get_services()
      (services || []).each do |service|
        provisioned_resources = []
        (service.get_destinations() || []).each do |resource_id|
          provisioned_resource = provision_provider.get_by_id(resource_id)
          unless provisioned_resource.nil?
            if provisioned_resource.is_provisioned?
              provisioned_resources.push(provisioned_resource)
            end
          end
        end

        if provisioned_resources.length() > 0
          element = Install::Definitions::InstalledService.new(service, provisioned_resources)
          elements.push(element)
        end
      end
      return elements
    end

  end
end