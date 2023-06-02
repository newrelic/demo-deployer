require './src/common/io/file_writer'
require './src/command_line/orchestrator'
require_relative "definitions/deployment"

require 'aws-sdk-sqs'

module Service
  class DeploymentRepository

    def initialize(
        context,
        sqs_client_lambda = nil
        )
      @context = context
      @sqs_client_lambda ||= lambda {return Aws::SQS::Client.new()}
      @sql_client = nil
    end

    def wait_next()
        while true
            wait_time_seconds = get_command_line_provider().get_wait_time_seconds()
            queue_url = get_command_line_provider().get_queue_url()
            resp = get_sqs_client().receive_message({
                queue_url: queue_url,
                wait_time_seconds: wait_time_seconds,
                max_number_of_messages: 1,
            })
            if resp.messages.length() > 0
                message_id = resp.messages[0].message_id
                receipt_handle = resp.messages[0].receipt_handle
                body = resp.messages[0].body
                attributes = resp.messages[0].attributes
                Common::Logger::LoggerFactory.get_logger().info("Got new message with message_id:#{message_id}")
                get_sqs_client().delete_message({
                    queue_url: queue_url,
                    receipt_handle: receipt_handle,
                })
                user_config_filename = @context.get_command_line_provider().get_user_config_filepath()
                deploy_config_filename = write_deploy_config(message_id, body)
                deployment = Definitions::Deployment.new(user_config_filename, deploy_config_filename)
                return deployment
            end
            sleep 1
        end
    end

    private
    def get_command_line_provider()
      return @context.get_command_line_provider()
    end

    def get_sqs_client()
        @sqs_client ||= @sqs_client_lambda.call()
        return @sqs_client
    end

    def write_deploy_config(message_id, content)
        app_config_provider = @context.get_app_config_provider()
        execution_path = app_config_provider.get_execution_path()
        filename = "#{message_id}.local.json"
        file_path = "#{execution_path}/#{filename}"
        file_writer = Common::Io::FileWriter.new(file_path, content)
        file_writer.execute()
        return file_path
    end

  end
end