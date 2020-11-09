require "./src/common/logger/logger_factory"
require "./src/common/tasks/process_task"

module AppConfig
  class Provider

    def initialize(config_file)
      @config_file = config_file || {}
    end

    def get_deployer_version()
      version = "#{@config_file["deployerMajorVersion"]}.#{@config_file["deployerMinorVersion"]}.#{@config_file["deployerBuildVersion"]}"
      return version
    end

    def get_execution_path()
      output_path = @config_file["executionPath"]
      return output_path
    end

    def get_summary_filename()
      filename = @config_file["summaryFilename"]
      return filename
    end

    def get_service_id_max_length()
      length = @config_file["serviceIdMaxLength"]
      return length
    end

    def get_aws_elb_port()
      port = @config_file["awsElbPort"]
      return port
    end

    def get_resource_id_max_length()
      length = @config_file["resourceIdMaxLength"]
      return length
    end

    def get_aws_ec2_supported_sizes()
      sizes = @config_file["awsEc2SupportedSizes"]
      return sizes
    end

    def get_aws_elb_max_listeners()
      maxListeners = @config_file["awsElbMaxListeners"]
      return maxListeners
    end

    def get_aws_api_gateway_sleep_time_seconds()
      return @config_file["awsApiGatewaySleepTimeSeconds"]
    end

    def get_azure_vm_supported_sizes()
      return @config_file["azureVmSupportedSizes"]
    end

    def get_gcp_compute_supported_sizes()
      return @config_file["gcpComputeSupportedSizes"]
    end

    def get_ansible_roles_path()
      raw = @config_file["ansibleRolesPath"]
      if raw != nil && raw.include?("$")
        process_command = "echo \"#{raw}\""
        task = Common::Tasks::ProcessTask.new(process_command, ".")
        process_output = task.wait_to_completion()
        if process_output.succeeded?
          return process_output.get_stdout()
        else
          error = process_output.get_error_message()
          Common::Logger::LoggerFactory.get_logger().error("Error while looking up ansible roles path with #{raw}, error:#{error}")
        end
      end
      return raw
    end
    
  end
end