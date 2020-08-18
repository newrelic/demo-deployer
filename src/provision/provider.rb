require "./src/provision/definitions/provisioned_resource"

module Provision
  class Provider

    def initialize(infrastructure_provider)
      @infrastructure_provider = infrastructure_provider
      @provisioned_resources = nil
    end

    def get_by_id(id)
      return get_all().find { |provisioned_resource| provisioned_resource.match_by_id(id) }
    end

    def find_or_throw(id)
      found = get_by_id(id)
      if found.nil?
        raise "Could not find provisioned resource with id:#{id}"
      end
      return found
    end

    def get_all()
      return @provisioned_resources ||= create_provisioned_resources()
    end

    private

    def create_provisioned_resources()
      elements = []
      resources = @infrastructure_provider.get_all()
      resources.each do |resource|
        element = Provision::Definitions::ProvisionedResource.new(resource)
        elements.push(element)
      end
      return elements
    end

  end
end