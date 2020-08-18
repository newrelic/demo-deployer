require "json"

module Infrastructure
  module Aws
    module Elb
      class ListenerValidator

        def initialize(max_listeners)
          @max_listeners = max_listeners
        end

        def execute(resources)
          invalid = []
          resources.each do |resource|
            listeners = resource["listeners"]
            if listeners.length > @max_listeners
              invalid.push(JSON.generate(resource))
            end
          end
          if invalid.length>0
            message = invalid.join(", ")
            
            return "Some load balancers exceed the maximum of #{@max_listeners} listeners : #{message}"
          end
          return nil
        end

      end
    end
  end
end

