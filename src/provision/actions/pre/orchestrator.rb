require "./src/common/logger/logger_factory"

require "./src/provision/actions/pre/pre_actions_factory"

module Provision
  module Actions
    module Pre
      class Orchestrator

        def initialize(
          context,
          pre_actions_factory = nil)

          @context = context
          @pre_actions_factory = pre_actions_factory
        end

        def execute()
          Common::Logger::LoggerFactory.get_logger().debug("Provision/Actions/Pre/Orchestrator execute()")
        
          @context.get_infrastructure_provider().get_all().each do |resource|
            pre_action = get_pre_actions_factory().create(resource)
            if pre_action != nil
              pre_action.execute(resource)
            end
          end
        end

        private
   
        def get_pre_actions_factory()
          return (@pre_actions_factory ||= PreActionsFactory.new(@context))
        end

      end
    end
  end
end