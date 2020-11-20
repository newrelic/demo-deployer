module Batch
  class Orchestrator

    def initialize(
        context
        )
      @context = context
    end

    def execute(arguments = ARGV)
      # @configuration_orchestrator.execute(arguments)
      # if is_teardown?()
      #   return @teardown_orchestrator.execute()
      # else
      #   @provision_orchestrator.execute()
      #   @install_orchestrator.execute()
      #   return @summary_orchestrator.execute()
      # end
    end

  end
end