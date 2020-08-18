require "./src/common/validation_error"
require "./src/common/validators/not_null_or_empty_validator"

module AppConfig
  class Validator

    def initialize(
      aws_elb_port_validator = Common::Validators::NotNullOrEmptyValidator.new("App Configuration file is missing \"awsElbPort\" value"),
      execution_path_validator = Common::Validators::NotNullOrEmptyValidator.new("App Configuration file is missing \"executionPath\" value"),
      summary_name_validator = Common::Validators::NotNullOrEmptyValidator.new("App Configuration file is missing \"summaryFilename\" value"),
      service_id_length_validator = Common::Validators::NotNullOrEmptyValidator.new("App Configuration file is missing \"serviceIdMaxLength\" value"),
      resource_id_length_validator = Common::Validators::NotNullOrEmptyValidator.new("App Configuration file is missing \"resourceIdMaxLength\" value"),
      aws_ec2_supported_sizes_validator = Common::Validators::NotNullOrEmptyValidator.new("App Configuration file is missing \"awsEc2SupportedSizes\" value"),
      aws_elb_max_listeners_validator = Common::Validators::NotNullOrEmptyValidator.new("App Configuration file is missing \"awsElbMaxListeners\" value")     
      )
      @aws_elb_port_validator = aws_elb_port_validator
      @execution_path_validator = execution_path_validator
      @summary_name_validator = summary_name_validator
      @service_id_length_validator = service_id_length_validator
      @resource_id_length_validator = resource_id_length_validator
      @aws_ec2_supported_sizes_validator = aws_ec2_supported_sizes_validator
      @aws_elb_max_listeners_validator = aws_elb_max_listeners_validator 
    end

    def execute(config)
      validators = [
        lambda { return @aws_elb_port_validator.execute(config['awsElbPort']) },
        lambda { return @execution_path_validator.execute(config['executionPath']) },
        lambda { return @summary_name_validator.execute(config['summaryFilename']) },
        lambda { return @service_id_length_validator.execute(config['serviceIdMaxLength']) },
        lambda { return @resource_id_length_validator.execute(config['resourceIdMaxLength']) },
        lambda { return @aws_ec2_supported_sizes_validator.execute(config['awsEc2SupportedSizes']) },
        lambda { return @aws_elb_max_listeners_validator.execute(config['awsElbMaxListeners']) }
      ]      
      validator = Common::Validators::Validator.new(validators)
      return validator.execute()
    end

  end
end