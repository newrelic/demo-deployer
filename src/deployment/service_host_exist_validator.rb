module Deployment
  class ServiceHostExistValidator

    def execute(services, resource_ids)
      missing = []
      services.each do |service|
        service.get_destinations().each do |destination|
          unless resource_ids.include?(destination)
            missing.push("#{service.get_id()}.#{destination}")
          end
        end
      end
      if missing.length>0
          serviceListMessage = missing.join(", ")
          return "The following services define destination hosts that do not exist under \"resources\" in deploy config file: #{serviceListMessage}"
      end
      return nil
    end
  end
end