require "./src/common/logger/logger_factory"

require "./src/teardown/actions/post/post_actions_factory"

module Teardown
  module Actions
    module Post
      class Orchestrator

        def initialize(
          context,
          post_actions_factory = nil)

          @context = context
          @post_actions_factory = post_actions_factory
        end

        def execute()
          Common::Logger::LoggerFactory.get_logger().debug("Teardown/Actions/Post/Orchestrator execute()")
        
          @context.get_infrastructure_provider().get_all().each do |resource|
            post_action = get_post_actions_factory().create(resource)
            if post_action != nil
              post_action.execute(resource)
            end
          end
        end

        private
   
        def get_post_actions_factory()
          return (@post_actions_factory ||= PostActionsFactory.new(@context))
        end

      end
    end
  end
end