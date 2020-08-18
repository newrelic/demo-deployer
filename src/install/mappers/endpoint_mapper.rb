require './src/common/template_merger'
require './src/common/text/field_merger_builder'
require "./src/install/service_field_merger_builder"

module Install
  module Mappers
    class EndpointMapper

      def initialize (services_provider, provision_provider, service_field_merger_builder = nil)
        @services_provider = services_provider
        @provision_provider = provision_provider
        @service_field_merger_builder = service_field_merger_builder || Install::ServiceFieldMergerBuilder.new()
      end

      def build_endpoint_map(service)
        endpoints = []

        field_merger = get_field_merger()
        service.get_endpoints().each do |endpoint|
          endpoints.push(field_merger.merge(endpoint))
        end

        return endpoints
      end

      private
      def get_field_merger()
        @field_merger ||= build_service_field_merger()
        return @field_merger
      end

      def build_service_field_merger()
        services = @services_provider.get_services()
        provisioned_resources = @provision_provider.get_all()
        field_merger = @service_field_merger_builder
          .with_services(services, provisioned_resources)
          .build()
        return field_merger
      end

    end
  end
end