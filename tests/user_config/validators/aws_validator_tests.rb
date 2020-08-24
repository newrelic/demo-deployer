require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/user_config/validators/aws_validator"

describe "UserConfig::Validators::AwsValidator" do
  let(:aws_configs) { [] }
  let(:api_key_validator) { m = mock(); m.stubs(:execute); m }
  let(:secret_key_validator) { m = mock(); m.stubs(:execute); m }
  let(:region_validator) { m = mock(); m.stubs(:execute); m }
  let(:validator) { UserConfig::Validators::AwsValidator.new(
    api_key_validator,
    secret_key_validator,
    region_validator
    ) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should execute api_key_validator" do
    given_aws_credential("my api key", "my secret key", "my secret key path", "my region")
    api_key_validator.expects(:execute)
    validator.execute(aws_configs)
  end

  it "should execute secret_key_validator" do
    given_aws_credential("my api key", "my secret key", "my secret key path", "my region")
    secret_key_validator.expects(:execute)
    validator.execute(aws_configs)
  end

  it "should execute region_validator" do
    given_aws_credential("my api key", "my secret key", "my secret key path", "my region")
    region_validator.expects(:execute)
    validator.execute(aws_configs)
  end

  def given_aws_credential(api_key = nil, secret_key = nil, secret_key_path = nil, region = nil)
    aws_config = { }
    unless api_key.nil?
      aws_config["apiKey"] = api_key
    end
    unless secret_key.nil?
      aws_config["secretKey"] = secret_key
    end
    unless secret_key_path.nil?
      aws_config["secretKeyPath"] = secret_key_path
    end
    unless region.nil?
      aws_config["region"] = region
    end
    aws_configs.push(aws_config)
  end

end