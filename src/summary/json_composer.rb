require 'time'
require 'json'

module Summary
  class JSONComposer

    def execute(provisioned_resources, installed_services, resource_instrumentors, service_instrumentors, global_instrumentors)
      summary = {}

      summary["global"] = get_global_summary(global_instrumentors) unless global_instrumentors.nil? || global_instrumentors.empty?

      summary["resources"] = get_resource_summary(installed_services, provisioned_resources, resource_instrumentors) unless provisioned_resources.nil?

      summary["services"] = get_service_summary(installed_services, provisioned_resources, service_instrumentors) unless installed_services.nil?
      summary["completed_at"] = Time.now()

      return summary.to_json()
    end

    private

    def get_global_summary(global_instrumentors)
      output = []
      global_instrumentors.each do |global_instrumentor|
        entry = {}
        identity = global_instrumentor.get_id()
        provider = global_instrumentor.get_provider()
        entry["id"] = identity
        entry["provider"] = provider
        output.push(entry)
      end
      return output
    end

    def get_resource_summary(installed_services, provisioned_resources, resource_instrumentors)
      output = []
      provisioned_resources.each do |provisioned_resource|
        entry = {}
        type = provisioned_resource.get_type()
        provider = provisioned_resource.get_provider()
        resource_id = provisioned_resource.get_id()
        access_point = get_resource_access_point(provisioned_resource)
        instrumentation_summary = get_instrumentation_summary(resource_id, resource_instrumentors)
        resource_services_summary = get_resource_services_summary(installed_services, resource_id)
        entry["id"] = resource_id
        entry["provider"] = provider
        entry["type"] = type
        entry["access_point"] = access_point unless access_point.empty?
        entry["services"] = resource_services_summary unless installed_services.nil? || resource_services_summary.empty?
        entry["instrumentation"] = instrumentation_summary unless resource_instrumentors.nil? || instrumentation_summary.empty?
        output.push(entry)
      end
      return output
    end

    def get_service_summary(installed_services, provisioned_resources, service_instrumentors)
      output = []
      installed_services.each do |installed_service|
        entry = {}
        service_id = installed_service.get_id()
        instrumentation_summary = get_instrumentation_summary(service_id, service_instrumentors)
        entry["id"] = service_id
        entry["urls"] = installed_service.get_urls()
        entry["instrumentation"] = instrumentation_summary unless service_instrumentors.nil? || instrumentation_summary.empty?
        output.push(entry)
      end
      return output
    end

    def get_resource_services_summary(installed_services, resource_id)
      output = []
      resource_services = get_resource_services(installed_services, resource_id)
      output = resource_services unless resource_services.empty?
      return output
    end

    def get_resource_services(installed_services, resource_id)
      collection = []
      installed_services.each do |installed_service|
        service = installed_service.get_service()
        collection.push(service.get_id()) if service.get_destinations().include?(resource_id)
      end
      return collection
    end

    def get_resource_access_point(provisioned_resource)
      output = {}
      unless provisioned_resource.get_url().nil?
        output["url"] = provisioned_resource.get_url()
      end

      unless provisioned_resource.get_ip().nil?
        output["ip"] = provisioned_resource.get_ip()
      end

      unless provisioned_resource.get_listeners().empty?
        output["listeners"] = provisioned_resource.get_listeners()
      end
      return output
    end

    def get_instrumentation_summary(id, instrumentors)
      output = []
      instrumentors.each do |instrumentor|
        if instrumentor.get_item_id() == id
          entry = {}
          entry["id"] = instrumentor.get_id()
          entry["provider"] = instrumentor.get_provider()
          version = instrumentor.get_version()
          entry["version"] = version unless version.nil?
          output.push(entry)
        end
      end
      return output
    end
  end
end
