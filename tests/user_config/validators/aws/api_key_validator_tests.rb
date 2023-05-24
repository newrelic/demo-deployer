require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/user_config/validators/aws/api_key_validator"

describe "UserConfig::Validators::Aws::ApiKeyValidator" do
  let(:aws_configs) { [] }
  let(:error_message_test) { "Error testing" }
  let(:validator) { UserConfig::Validators::Aws::ApiKeyValidator.new(error_message_test) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should execute api_key_validator" do
    given_aws_credential("my api key", "my secret key", "my secret key path", "my region", "my session token")
    validator.execute(aws_configs)
  end

  it "should validate session token exist when applicable" do
    given_aws_credential("ASIA and anything after", "my secret key", "my secret key path", "my region")
    errorMessage = validator.execute(aws_configs)
    errorMessage.wont_be_nil()
    errorMessage.must_include(error_message_test)
    errorMessage.must_include("ASIA")
  end

  it "should validate when session token in used" do
    given_aws_credential("ASIA and anything after", "my secret key", "my secret key path", "my region", "A valid token")
    errorMessage = validator.execute(aws_configs)
    errorMessage.must_be_nil()
  end

  it "should validate session token does not exist when not applicable" do
    given_aws_credential("AKIA and anything after", "my secret key", "my secret key path", "my region", "A valid token")
    errorMessage = validator.execute(aws_configs)
    errorMessage.wont_be_nil()
    errorMessage.must_include(error_message_test)
    errorMessage.must_include("AKIA")
  end

  it "should validate when no session token in used" do
    given_aws_credential("AKIA and anything after", "my secret key", "my secret key path", "my region")
    errorMessage = validator.execute(aws_configs)
    errorMessage.must_be_nil()
  end

  def given_aws_credential(api_key = nil, secret_key = nil, secret_key_path = nil, region = nil, session_token = nil)
    aws_config = {}
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
    unless session_token.nil?
      aws_config["sessionToken"] = session_token
    end
    aws_configs.push(aws_config)
  end

end