require "./src/provision/templates/template_context.rb"

module Provision
  module Templates
    module Aws
      module R53Ip
        class R53IpTemplateContext < TemplateContext

          def initialize(output_file_path, template_file_path, context, resource)
            super(output_file_path, template_file_path, context, resource)
          end

          def get_template_input_file_path()
            return "#{get_template_file_path()}/template.erb"
          end

          def get_template_output_file_path()
            return "#{get_output_file_path()}/r53ip.yml"
          end

          def get_template_binding()
            template_binding = Kernel.binding()
            template_context = {}

            parse_credential(template_context, get_resource().get_credential())
            parse_infrastructure_resource(template_context)
            parse_deployment(template_context)

            template_binding.local_variable_set("r53", template_context)

            return template_binding
          end

          def parse_credential(template_context, credential)
            template_context[:aws_access_key] = credential.get_api_key()
            template_context[:aws_secret_key] = credential.get_secret_key()
            template_context[:aws_region] = credential.get_region()
          end

          def parse_infrastructure_resource(template_context)
            template_context[:resource_id] = get_resource_id()
          end

          def parse_deployment(template_context)
            field_merger = Install::ServiceFieldMergerBuilder.create(get_context())
            deployment_name = get_deployment_name()
            template_context[:deployment_name] = deployment_name
            template_context[:domain] = get_resource().get_domain()
            dns = get_resource().get_dns()
            template_context[:dns] = dns
            listeners = get_resource().get_listeners()
            ips = get_listener_ips(listeners)
            if ips.empty?
              reference_resource_name = get_reference_resource_name()
              template_context[:reference_resource_name] = reference_resource_name
            else
              port = get_first_listener_port(listeners)
              template_context[:ips] = ips
              template_context[:port] = port
            end
            template_context[:artifact_file_path] = get_output_file_path()
          end

          private
          def get_listener_ips(listeners)
            all_ips = []
            (listeners || []).each do |listener|
              service = get_services_provider().get_by_id(listener)
              destinations = service.get_destinations()
              destinations.each do |resource_id|
                resource = get_provision_provider().get_by_id(resource_id)
                ip = resource.get_ip()
                unless ip.nil?
                  unless all_ips.include?(ip)
                    all_ips.push(ip)
                  end
                end
              end
            end
            return all_ips.join(',')
          end

          def get_first_listener_port(listeners)
            (listeners || []).each do |listener|
              service = get_services_provider().get_by_id(listener)
              return service.get_port()
            end
            return nil
          end

          def get_reference_resource_name()
            reference_id = get_resource().get_reference_id()
            deployment_name = get_deployment_name()
            return "#{deployment_name}-#{reference_id}"
          end

        end
      end
    end
  end
end