require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/app_config/validator"

describe "AppConfig::Validator" do
  describe "execute" do

    let(:config) {{"executionPath"=>"path", "summaryFilename"=>"filename.txt", "serviceIdMaxLength"=>99, "resourceIdMaxLength"=>99, "awsEc2SupportedSizes"=>["t2.nino", "t2.micra", "t2.smallz", "t2.mediums"], "awsElbPort"=>45, "awsElbMaxListeners"=>99}}
    
    let(:aws_elb_port_validator) { m = mock(); m.stubs(:execute); m }
    let(:execution_path_validator) { m = mock(); m.stubs(:execute); m }
    let(:summary_name_validator) { m = mock(); m.stubs(:execute); m }
    let(:service_id_length_validator) { m = mock(); m.stubs(:execute); m }
    let(:resource_id_length_validator) { m = mock(); m.stubs(:execute); m }
    let(:aws_ec2_supported_sizes_validator) { m = mock(); m.stubs(:execute); m }
    let(:aws_elb_max_listeners_validator) { m = mock(); m.stubs(:execute); m }

    let(:validator) { AppConfig::Validator.new(
      aws_elb_port_validator,
      execution_path_validator,
      summary_name_validator,
      service_id_length_validator,
      resource_id_length_validator,
      aws_ec2_supported_sizes_validator,
      aws_elb_max_listeners_validator)}

    it "should create validator" do
      validator.wont_be_nil
    end

     it "should execute aws_elb_port_validator" do
      aws_elb_port_validator.expects(:execute)
      expect(validator.execute(config))
    end

    it "should execute execution_path_validator" do
      execution_path_validator.expects(:execute)
      expect(validator.execute(config))
    end

    it "should execute summary_name_validator" do
      summary_name_validator.expects(:execute)
      expect(validator.execute(config))
    end

    it "should execute service_id_length_validator" do
      service_id_length_validator.expects(:execute)
      expect(validator.execute(config))
    end

    it "should execute resource_id_length_validator" do
      resource_id_length_validator.expects(:execute)
      expect(validator.execute(config))
    end

    it "should execute aws_ec2_supported_sizes_validator" do
      aws_ec2_supported_sizes_validator.expects(:execute)
      expect(validator.execute(config))
    end

    it "should execute aws_elb_max_listeners_validator" do
      aws_elb_max_listeners_validator.expects(:execute)
      expect(validator.execute(config))
    end

  end
end