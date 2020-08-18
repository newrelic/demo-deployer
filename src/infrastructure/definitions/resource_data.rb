require "./src/common/install/params"

module Infrastructure
  module Definitions
    class ResourceData

      def initialize (id, provider, provision_group)
        @id = id.downcase
        @display_name = @id
        @provider = provider
        @provision_group = provision_group
        @params = Common::Install::Params.new()
      end

      def ==(other_resource)
        return match_by_id(other_resource.get_id())
      end

      def match_by_id(id)
        return (id != nil && @id == id.downcase)
      end

      def match_by_provision_group(provision_group)
        return (provision_group != nil && @provision_group == provision_group)
      end

      def get_id()
        return @id
      end

      def get_display_name()
        return @display_name
      end

      def set_display_name(display_name)
        @display_name = display_name
      end

      def get_provider()
        return @provider
      end

      def get_provision_group()
        return @provision_group
      end

      def get_params()
        return @params
      end

      def to_s()
        return "ResourceData id:#{@id} provider:#{@provider} provision_group:#{@provision_group} params:#{@params}"
      end

    end
  end
end
