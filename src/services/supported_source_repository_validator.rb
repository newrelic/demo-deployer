require 'json'

module Services
  class SupportedSourceRepositoryValidator

    def initialize(patterns, error_message = nil)
      @patterns = patterns || []
      @error_message = error_message || "Error"
    end

    def execute(services)
      invalid = []

      (services || []).each do |service|
        source_repository = service['source_repository']
        if source_repository.nil?
          next
        end
        unless @patterns.any?{ |pattern| source_repository.include?(pattern)}
          invalid.push(JSON.generate(service))
        end
      end

      if invalid.length>0
        return "#{@error_message} #{@patterns.join(", ")} #{invalid.join(", ")}"
      end

      return nil
    end

  end
end
