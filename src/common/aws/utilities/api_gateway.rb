require 'aws-sdk-core'
require 'aws-sdk-apigateway'

module Common
  module Aws
    module Utilities
      class ApiGateway

        def initialize(credential)
          @credential = credential
        end

        def delete_api_gateway_by_name(api_gateway_name)
          api_id = get_api_gateway_id_by_name(api_gateway_name)
          unless api_id.nil?
            apigateway = get_api_gateway_client()
            apigateway.delete_rest_api({ rest_api_id: api_id })
          end
        end

        def get_api_gateway_id_by_name(api_gateway_name)
            apigateway = get_api_gateway_client()
            gateway_id = nil

            response = {response: nil}
            loop do
              response = apigateway.get_rest_apis({ limit: 50, position: response[:position] })
              response.items.each do |api_gateway|
                if api_gateway[:name] == api_gateway_name
                  gateway_id = api_gateway[:id]
                  break
                end
              end
              break if response[:position].nil?
            end

            return gateway_id
        end

        private

        def get_api_gateway_client()
          @apigateway ||= ::Aws::APIGateway::Client.new(
            region: @credential.get_region(),
            credentials: ::Aws::Credentials.new(@credential.get_access_key(), @credential.get_secret_key())
          )
          return @apigateway
        end
      end
    end
  end
end
