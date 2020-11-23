require "./src/common/logger/logger_factory"
require "./src/common/text/field_merger_builder"
require "./src/common/text/global_field_merger_builder"
require "./src/common/text/credential_field_merger_builder"
require "./src/common/text/app_config_field_merger_builder"

module Install
  class ServiceFieldMergerBuilder

    def initialize(field_merger_builder = nil)
      @field_merger_builder = field_merger_builder || Common::Text::FieldMergerBuilder.new()
    end

    def with_services(services, provisioned_resources)
      (provisioned_resources || []).each do |provisioned_resource|
        id  = provisioned_resource.get_id()
        url = provisioned_resource.get_url()
        @field_merger_builder.create_definition(["resource", id], url)
        @field_merger_builder.create_definition(["resource", id, "url"], url)
        @field_merger_builder.create_definition(["resource", id, "display_name"], provisioned_resource.get_resource().get_display_name())
        @field_merger_builder.create_definition(["resource", id, "ip"], provisioned_resource.get_ip())
        @field_merger_builder.create_definition(["resource", id, "private_dns_name"], provisioned_resource.get_private_dns_name())
        @field_merger_builder.create_definition(["resource", id, "instance_id"], provisioned_resource.get_instance_id())
      end

      (services || []).each do |service|
        id  = service.get_id()
        destination_id = service.get_destinations().sample()
        provisioned_resource = (provisioned_resources || []).find() {|provisioned_resource| provisioned_resource.match_by_id(destination_id)}
        unless provisioned_resource.nil?
          url = build_url(service, provisioned_resource)
          if url.nil?
            Common::Logger::LoggerFactory.get_logger().info("Could not build a url for service #{id} while building service merge fields, ignoring this field.")
          else
            @field_merger_builder.create_definition(["service", id], url)
            @field_merger_builder.create_definition(["service", id, "url"], url)
          end
        end
        port = service.get_port()
        unless port.nil?
          port = port.to_s()
        end
        @field_merger_builder.create_definition(["service", id, "port"], port)
        display_name = service.get_display_name()
        @field_merger_builder.create_definition(["service", id, "display_name"], display_name)
      end

      return self
    end

    def with_global(context)
      merger = Common::Text::GlobalFieldMergerBuilder.create(context)
      @field_merger_builder.append_definitions(merger.get_definitions())
      return self
    end

    def with_user_credentials(context)
      merger = Common::Text::CredentialFieldMergerBuilder.create(context)
      @field_merger_builder.append_definitions(merger.get_definitions())
      return self
    end

    def with_app_config(context)
      merger = Common::Text::AppConfigFieldMergerBuilder.create(context)
      @field_merger_builder.append_definitions(merger.get_definitions())
      return self
    end

    def build()
      return @field_merger_builder.build()
    end

    def self.create(context)
      instance = ServiceFieldMergerBuilder.new()
      services = context.get_services_provider().get_all()
      provisioned_resources = []
      provision_provider = context.get_provision_provider()
      unless provision_provider.nil?
        provisioned_resources = provision_provider.get_all()
      end
      instance.with_services(services, provisioned_resources)
      instance.with_global(context)
      instance.with_user_credentials(context)
      instance.with_app_config(context)
      return instance.build()
    end

    private

    def build_url(service, provisioned_resource)
      host_ip = provisioned_resource.get_ip()

      if !host_ip.nil?
        return "http://#{host_ip}:#{service.get_port()}"
      end

      url = provisioned_resource.get_url()
      if !url.nil?
        if url.start_with?("http") == false
          url = "http://" +url
        end
        return url
      end

      return nil
    end

  end
end
