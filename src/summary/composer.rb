require 'time'

module Summary
  class Composer

    def execute(provisioned_resources, installed_services, resource_instrumentors, service_instrumentors, global_instrumentors)
      summary = ""

      summary += get_global_summary(global_instrumentors) unless global_instrumentors.nil? || global_instrumentors.empty?
      summary += "\n"

      summary += get_resource_summary(installed_services, provisioned_resources, resource_instrumentors) unless provisioned_resources.nil?
      summary += "\n"

      summary += get_service_summary(installed_services, provisioned_resources, service_instrumentors) unless installed_services.nil?
      summary += "Completed at #{Time.now}\n"
      summary += "\n"
      return summary
    end

    private

    def get_global_summary(global_instrumentors)
      output = "Global Instrumentation:\n\n"
      global_instrumentors.each do |global_instrumentor|
        identity = global_instrumentor.get_id()
        provider = global_instrumentor.get_provider()
        output += "  #{identity} (#{provider})\n"
        output += "\n"
      end
      return output
    end

    def get_resource_summary(installed_services, provisioned_resources, resource_instrumentors)
      output = "Deployed Resources:\n\n"
      provisioned_resources.each do |provisioned_resource|
        type = provisioned_resource.get_type()
        provider = provisioned_resource.get_provider()
        resource_id = provisioned_resource.get_id()
        access_point = get_resource_access_point(provisioned_resource)
        instrumentation_summary = get_instrumentation_summary(resource_id, resource_instrumentors)
        resource_services_summary = get_resource_services_summary(installed_services, resource_id)
        output += "  #{resource_id} (#{provider}/#{type}):\n"
        output += "    #{access_point}" unless access_point.empty?
        output += "    #{resource_services_summary}" unless installed_services.nil? || resource_services_summary.empty?
        output += "    #{instrumentation_summary}" unless resource_instrumentors.nil? || instrumentation_summary.empty?
        output += "\n"
      end
      return output
    end

    def get_service_summary(installed_services, provisioned_resources, service_instrumentors)
      output = "Installed Services:\n\n"
      installed_services.each do |installed_service|
        service_id = installed_service.get_id()
        instrumentation_summary = get_instrumentation_summary(service_id, service_instrumentors)
        output += "  #{service_id}:\n"
        installed_service.get_urls().each do |url|
          output += "    url: #{url}\n" unless url.nil?
        end
        output += "    #{instrumentation_summary}" unless service_instrumentors.nil? || instrumentation_summary.empty?
        output += "\n"
      end
      return output
    end

    def get_resource_services_summary(installed_services, resource_id)
      output = ""
      resource_services = get_resource_services(installed_services, resource_id)
      output += "services: #{resource_services}\n" unless resource_services.empty?()
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
      output = ""
      unless provisioned_resource.get_url().nil?
        output += "url: #{provisioned_resource.get_url()}\n"
      end

      unless provisioned_resource.get_ip().nil?
        output += "ip: #{provisioned_resource.get_ip()}\n"
      end

      unless provisioned_resource.get_listeners().empty?
        output += "    listeners: #{provisioned_resource.get_listeners()}\n"
      end
      return output
    end

    def get_instrumentation_summary(id, instrumentors)
      output = ""
      instrumentation_summary_lines = get_instrumentation_summary_lines(id, instrumentors)
      unless instrumentation_summary_lines.empty?()
        output += "instrumentation: \n"
        instrumentation_summary_lines.each do |line|
          output += "       #{line} \n"
        end
      end
      return output
    end

    def get_instrumentation_summary_lines(id, instrumentors)
      info = []
      instrumentors.each do |instrumentor|
        if instrumentor.get_item_id() == id
          output = "#{instrumentor.get_id()}:"
          output += " #{instrumentor.get_provider()}"
          version = instrumentor.get_version()
          unless version.nil?
            output += " v#{version}"
          end
          info.push(output)
        end
      end
      return info
    end

  end
end
