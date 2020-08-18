module Services
  class PortDestinationValidator

    def initialize(error_message = nil)
      @error_message = error_message || "Error"
    end

    def execute(services)       
      destinations = create_destinations(services)
      destination_groups = destinations.group_by {|x| x[:destination] }
      invalid = find_overlapping(destination_groups)
      if invalid.length > 0
        return "#{@error_message} #{invalid.join(", ")}"
      end
      return nil
    end

    private

    def create_destinations(services)
      destinations = []
      services.each do |service|        
        (service['destinations'] || []).each do |destination|
          destinations.push({id: service['id'], port: service['port'], destination: destination})
        end
      end
      return destinations
    end
    
    def find_overlapping(destination_groups)
      result = []
      destination_groups.each do |dest, services|       
        port_group = services.group_by {|x| x[:port]}
        port_group.each do |port, services|          
          if services.length > 1
            overlapping = []       
            services.each do |service|
              overlapping.push("#{service[:id]}-#{port}")    
            end
            result.push(dest => overlapping)
            overlapping = []
          end
        end   
      end
      return result
    end  

  end
end
