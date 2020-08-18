require "mocha/minitest"
require "./user_acceptance_tests/assertions/http_client"

module UserAcceptanceTests
  module Assertions
      class ServiceBehaviorResponse

        def initialize(context)
          @context = context
        end

        def execute(path, service_id, headers = {}, check_response_proc = nil)
          installed_service = @context.get_install_provider().get_by_id(service_id)
          if installed_service.nil?
            raise "Service id #{service_id} was not found in install config"
          else
            url = installed_service.get_urls(path).first()
            if url.nil? || url == ""
              raise "Service #{service_id} has not api url "
            end
            response = HttpClient.execute(url, headers)
            unless check_response_proc.nil?
              check_response_proc.call(response, service_id)
            end
          end
          return true
        end

      end
  end
end
