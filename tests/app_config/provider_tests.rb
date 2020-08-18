require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/app_config/provider"

describe "AppConfig::Provider" do
  let(:app_config) {{"executionPath"=>"path", "summaryFilename"=>"filename.txt", "serviceIdMaxLength"=>99, "resourceIdMaxLength"=>99, "awsEc2SupportedSizes"=>["t2.nino", "t2.micra", "t2.smallz", "t2.mediums"], "awsElbPort"=>45, "awsElbMaxListeners"=>99}}
  let(:provider) { AppConfig::Provider.new(app_config)}

  it "should create provider" do
    provider.wont_be_nil
  end

  describe "get_execution_path" do
    it "should get execution path if it exists" do      
      expect(provider.get_execution_path).must_equal("path")
    end
  end

  describe "get_summary_filename" do
    it "should get summary filename if it exists" do      
      expect(provider.get_summary_filename).must_equal("filename.txt")
    end
  end

  describe "get_service_id__max_length" do
    it "should get service_id_max_length if it exists" do      
      expect(provider.get_service_id_max_length).must_equal(99)
    end
  end

  describe "get_resource_id_max_length" do
    it "should get resource id max length if it exists" do      
      expect(provider.get_resource_id_max_length).must_equal(99)
    end
  end

  describe "get_aws_elb_port" do
    it "should get resource elb port if it exists" do
      provider.get_aws_elb_port().must_equal(45)
    end
  end

  describe "get_aws_ec2_supported_sizes" do
    it "should get an array of supported ec2 sizes if they exists" do
      provider.get_aws_ec2_supported_sizes().length.must_equal(4)
    end
  end

  describe "get_aws_elb_max_listeners" do
    it "should get max number of listeners associated with an ELB if it exists" do
      provider.get_aws_elb_max_listeners().must_equal(99)
    end
  end

end