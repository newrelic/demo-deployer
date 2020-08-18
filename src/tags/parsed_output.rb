require 'json'

module Tags
  class ParsedOutput

    def initialize(global_tags, services_tags, resources_tags)
      @global_tags = global_tags || {}
      @services_tags = services_tags || {}
      @resources_tags = resources_tags || {}
    end

    def get_global_tags()
      return @global_tags
    end

    def get_services_tags()
      return @services_tags
    end

    def get_resources_tags()
      return @resources_tags
    end

  end
end
