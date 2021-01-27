module Provision
  module Definitions
    class ProvisionedResource

      def initialize(resource)
        @resource = resource
      end

      def get_id()
        return @resource.get_id()
      end

      def get_ip()
        return get_param("ip")
      end

      def get_url()
        url = get_param("url")
        if url!=nil && url.start_with?("http") == false
          url = "http://" +url
        end
        return url
      end

      def get_private_dns_name()
        return get_param("private_dns_name")
      end

      def get_instance_id()
        return get_param("instance_id")
      end

      def get_user_name()
        return @resource.get_user_name()
      end

      def get_credential()
        return @resource.get_credential()
      end

      def get_type()
        return @resource.get_type()
      end

      def get_provider()
        return @resource.get_provider()
      end

      def get_listeners()
        if @resource.respond_to?(:get_listeners)
         return @resource.get_listeners()
       end
       return []
      end

      def get_params()
        return @resource.get_params()
      end

      def get_param(key)
        return get_params().get(key)
      end

      def is_provisioned?()
        if (get_ip().nil? && get_url().nil?)
          return false
        end
        return true
      end

      def get_resource()
        return @resource
      end

      def ==(other)
        return other != nil && match_by_id(other.get_id())
      end

      def match_by_id(id)
        return (id != nil && @resource.get_id() == id)
      end

      def to_s()
        return "ProvisionedResource is_provisioned:#{is_provisioned?()} #{@resource}"
      end

    end
  end
end