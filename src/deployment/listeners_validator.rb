module Deployment
  class ListenersValidator

    def initialize(type)
      @type = type
    end

    def execute(resources)
      missing = []
      dependency_resources = resources.select {|resource| resource.instance_of?(@type) }
      unless dependency_resources.empty?
        dependency_resources.each do |resource|
          field = resource.get_listeners()
          if field.nil? || field.empty?
            missing.push(resource.get_id())
          end
        end
      end

      if missing.length > 0
        return "The following does NOT have a listener defined: '#{missing.join('|')}'"
      end

      return nil
    end

  end
end