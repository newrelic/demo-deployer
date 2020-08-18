module Deployment
  class ListenersAllOnSamePortValidator

    def initialize(type)
      @type = type
    end

    def execute(resources, services)
      found_dupes = []

      resources_to_search = resources.select {|resource| resource.instance_of?(@type) }
      services_ports = services.collect { |x| [ x.get_id(), x.get_port()] }.compact().to_h

      unless resources_to_search.nil?
        resources_to_search.each do |resource|
          ports_found = {}
          resource.get_listeners().each do |listener|
            service_port = services_ports[listener]
            ports_found[service_port] ||= []
            ports_found[service_port].push(listener)
          end

          if ports_found.size() > 1
            dup_service_ports = ports_found.collect {|port, listeners| listeners.collect{ |listener| "#{listener}(#{port})"} }
            found_dupes.push("The '#{resource.get_id()}' ELB has listeners with different ports #{dup_service_ports.join('|')}")
          end

        end
      end

      if found_dupes.length > 0
          return found_dupes.join(", ")
      end
      return nil
    end

  end
end