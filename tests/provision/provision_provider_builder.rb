require "json"
require "./src/provision/provider"

module Tests
  module Provision
    class ProvisionProviderBuilder

      def initialize(parent_builder)
        @parent_builder = parent_builder
        @provider = nil
        @output_params = []
      end

      def build(context)
        return @provider ||= createInstance(context)
      end

      def service(id, params)
        output_param = {}
        output_param["id"] = id
        params.each do |k,v|
          output_param[k] = v
        end
        @output_params.push(output_param)
      end

      def service_host(id, ip)
        output_param = {}
        output_param["id"] = id
        output_param["ip"] = ip
        @output_params.push(output_param)
      end

      def service_endpoint(id, url)
        output_param = {}
        output_param["id"] = id
        output_param["url"] = url
        @output_params.push(output_param)
      end

      private

      def createInstance(context)
        infrastructure_provider = context.get_infrastructure_provider()
        @output_params.each do |output_param|
          id = output_param["id"]
          resource = infrastructure_provider.get_by_id(id)
          unless resource.nil?
            output_param.each do |k,v|
              unless k=="id"
                resource.get_params().add(k, v)
              end
            end

            # ip = output_param["ip"]
            # unless ip.nil?
            #   resource.get_params().add("ip", ip)
            # end
            # url = output_param["url"]
            # unless url.nil?
            #   resource.get_params().add("url", url)
            # end
          end
        end
        provider = ::Provision::Provider.new(infrastructure_provider)
        context.set_provision_provider(provider)
        return provider
      end

    end
  end
end
