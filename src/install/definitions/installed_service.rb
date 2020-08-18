module Install
  module Definitions
    class InstalledService

      def initialize(service, provisioned_resources)
        @service = service
        @provisioned_resources = provisioned_resources
      end

      def get_id()
        return @service.get_id()
      end
      
      def get_service()
        return @service
      end

      def get_provisioned_resources()
        return @provisioned_resources || []
      end

      def get_urls(suffix = nil)
        urls = []
        unless @service.nil?
          get_provisioned_resources().each do |provisioned_resource|
            if @service.get_destinations().include?(provisioned_resource.get_id())
              url = provisioned_resource.get_url()
              if url.nil?
                port = @service.get_port()
                ip = provisioned_resource.get_ip()
                unless ip.nil?
                  url = "http://#{ip}:#{port}"
                end
              end
              unless url.nil?
                unless suffix.nil?
                  url = "#{url}/#{suffix}"
                end
                urls.push(url)
              end
            end
          end
        end
        return urls
      end

      def ==(other)
        return other != nil && match_by_id(other.get_id())
      end

      def match_by_id(id)
        return (id != nil && get_id() == id)
      end

      def to_s()
        return "InstalledService #{@service} #{@provisioned_resources}"
      end

    end
  end
end