require "mocha/minitest"
require "./user_acceptance_tests/assertions/http_client"

module UserAcceptanceTests
  module Assertions
      class ServiceRelationship

        def initialize(context)
          @context = context
        end

        def execute(paths, service_ids = [])
          has_failed = false
          service_ids.each do |service_id|
            installed_service = @context.get_install_provider().get_by_id(service_id)
            unless installed_service.nil?
              service = installed_service.get_service()
              installed_service.get_urls("api").each do |url|
                if !(url.nil? || url.empty?)
                  puts "validating service #{service.get_id()} with url #{url}\n"

                  expected_trace = ""
                  current_service = service
                  loop do
                    relationship = current_service.get_relationships().first()
                    break if relationship.nil? || relationship.empty?
                    current_service = @context.get_services_provider().get_by_id(relationship)
                    break if current_service.nil?
                    if current_service.get_destinations().length() > 0
                      expected_trace += ",#{current_service.get_id()}"
                    end
                  end

                  expected_trace = "#{service.get_id()}#{expected_trace}"
                  paths.each do |path|
                    ok = assert_service_relationship(url +"/#{path}", expected_trace)
                    if ok == false
                      has_failed = true
                    end
                  end
                end
              end
            else
              raise "Could not find installed service with id #{service_id}"
            end
          end
          if has_failed == true
            raise "At least 1 service and path did NOT validate correctly"
          end
        end

        def assert_service_relationship(url, expected_trace)
          headers = { "X-DEMOTRON-TRACE": true }
          response = HttpClient.execute(url, headers)
          if response.nil?
            raise "No http response when requesting #{url}"
          end

          trace = response["X-DEMOTRON-TRACE"]
          begin
            if trace != nil
              trace.must_include(expected_trace)
              return true
            end
          rescue Exception => e
            puts "Trace response #{trace} does NOT contain expected #{expected_trace}, detail:#{e}\n"
          end

          return false
        end

      end
  end
end