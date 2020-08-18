require "json"

module Common
  module Validators
    class SizeValidator

      def initialize(sizes_supported)
        @sizes_supported = sizes_supported
      end

      def execute(resources)
        invalid = []
        resources.each do |resource|
          size = resource["size"]
          if @sizes_supported.include?(size)==false
            invalid.push(JSON.generate(resource))
          end
        end
        if invalid.length>0
          message = invalid.join(", ")
          return "Some resources have an invalid size for the provider: #{message}, allowed sizes are [#{@sizes_supported.join(", ")}]"
        end
        return nil
      end

    end
  end
end