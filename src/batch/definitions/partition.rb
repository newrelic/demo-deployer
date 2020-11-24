module Batch
  module Definitions
    class Partition
      def initialize(id, max_capacity)
        @id = id
        @max_capacity = max_capacity
        @deployment = {}
      end

      def get_id()
        return @id
      end

      def add_deployment(deployment)
        deployment_name = deployment.get_deployment_name()
        if has_available_space?() == false
          raise "Cannot add deployment to this partition, partition is full, deployment_name:#{deployment_name}"
        end
        @deployment[deployment_name] = deployment
      end

      def get_by_deployment_name(deployment_name)
        return @deployment[deployment_name]
      end

      def has_deployment_name?(deployment_name)
        return @deployment.key?(deployment_name)
      end

      def has_available_space?()
        return @deployment.length < @max_capacity
      end

      def get_all_deployments()
        return @deployment.values
      end

      def to_s()
        return "Partition id:#{get_id()} deployment_names:#{@deployment.keys.join(",")}"
      end

    end
  end
end