require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/credential_exist_validator"

describe "Deployment::CredentialExistValidator" do
  let(:credential) { {} }
  let(:error_message) { "This is an error message for test purpose:" }
  let(:user_config_provider) { m = mock(); m.stubs(:get_credential); m }
  let(:validator) { Deployment::CredentialExistValidator.new(user_config_provider, error_message) }

  it "should create validator" do
    validator.wont_be_nil()
  end

  it "should error when credential missing" do
    error = validator.execute("datanerd")
    error.must_include(error_message)
    error.must_include("datanerd")
  end
  
  it "should NOT error when credential is defined" do
    given_credential("datanerd")
    validator.execute("datanerd").must_be_nil()
  end

  def given_credential(provider)
    user_config_provider.stubs(:get_credential).with(provider).returns(credential)
  end
  
end