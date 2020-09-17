require "json"
require "./src/infrastructure/orchestrator"

module Tests
  module Infrastructure
    class InfrastructureProviderBuilder

      def initialize(parent_builder)
        @parent_builder = parent_builder
        @content = {}
        @provider = nil
      end

      def with_resource(id, others = nil)
        create_new_resource(id, others)
        return @parent_builder
      end

      def ec2(id, size = "t2.small")
        resource = create_new_resource(id)
        resource["provider"] = "aws"
        resource["type"] = "ec2"
        resource["size"] = size
        return @parent_builder
      end
      
      def vm(id, size = "Standard_B1s")
        resource = create_new_resource(id)
        resource["provider"] = "azure"
        resource["type"] = "vm"
        resource["size"] = size
        return @parent_builder
      end

      def r53ip(id, domain, service_ids)
        resource = create_new_resource(id)
        resource["provider"] = "aws"
        resource["type"] = "r53ip"
        resource["domain"] = domain
        listeners = get_or_create(resource, "listeners", [])
        (service_ids || []).compact().each do |service_id|
          listeners.push(service_id)
        end
        return @parent_builder
      end

      def s3(id, bucket_name)
        resource = create_new_resource(id)
        resource["provider"] = "aws"
        resource["type"] = "s3"
        resource["bucket_name"] = bucket_name
        return @parent_builder
      end

      def r53ip_reference(id, domain, reference_id)
        resource = create_new_resource(id)
        resource["provider"] = "aws"
        resource["type"] = "r53ip"
        resource["domain"] = domain
        resource["reference_id"] = reference_id
        return @parent_builder
      end

      def elb(id, service_ids)
        resource = create_new_resource(id)
        resource["provider"] = "aws"
        resource["type"] = "elb"
        listeners = get_or_create(resource, "listeners", [])
        (service_ids || []).compact().each do |service_id|
          listeners.push(service_id)
        end
        return @parent_builder
      end
      
      def lambda(id)
        resource = create_new_resource(id)
        resource["provider"] = "aws"
        resource["type"] = "lambda"
        return @parent_builder
      end

      def build(context)
        return @provider ||= createInstance(context)
      end

      private
      def create_new_resource(id, others = nil)
        resources = get_or_create(@content, "resources", [])
        resource = {}
        unless others.nil?
          resource = resource.merge(others)
        end
        resource["id"] = id
        resources.push(resource)
        return resource
      end

      def get_or_create(instance, key, default)
        found = instance[key]
        if found.nil?
          instance[key] = default
        end
        return instance[key]
      end

      def createInstance(context)
        get_or_create(@content, "resources", [])
        orchestrator = ::Infrastructure::Orchestrator.new(context, nil, nil, false)
        return orchestrator.execute(@content.to_json())
      end

    end
  end
end