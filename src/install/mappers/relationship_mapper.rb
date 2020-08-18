module Install
  module Mappers
    class RelationshipMapper

      def initialize (services_provider, provision_provider)
        @services_provider = services_provider
        @provision_provider = provision_provider
      end

      def build_relationship_map(service)
        dependencies = []
        relationships = service.get_relationships()
        relationships.each do |relation_service_id|
          dependency = build_dependencies(relation_service_id)
          dependencies.push(dependency)
        end
        return dependencies
      end

      private
      def build_dependencies(relation_service_id)
        relation_service = @services_provider.get_by_id(relation_service_id)
        if !relation_service.nil?
          return build_service_dependencies(relation_service)
        end

        relation_resource = @provision_provider.get_by_id(relation_service_id)
        if !relation_resource.nil?
          return build_resource_dependencies(relation_resource)
        end

        raise "Install Relationship Mapper couldn't find a service or resource to resolve downstream dependencies."
      end

      def build_service_dependencies(relation_service)
        dependency = {}
        dependency[:id] = relation_service.get_id()

        urls = []
        relation_service.get_destinations().each do |resource_id|
          provisioned_resource = @provision_provider.get_by_id(resource_id)
          url = build_url(provisioned_resource, relation_service)
          urls.push(url)
        end
        dependency[:urls] = urls

        return dependency
      end

      def build_resource_dependencies(relation_resource)
        dependency = {}

        dependency[:id] = relation_resource.get_id()

        urls = []
        url = relation_resource.get_url()
        urls.push(url)
        dependency[:urls] = urls

        return dependency
      end

      def build_url(provisioned_resource, service)
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

        raise "Install Relationship Mapper couldn't build a url for '#{provisioned_resource.get_id()}'."
      end

    end
  end
end
