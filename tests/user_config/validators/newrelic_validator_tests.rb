require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/user_config/validators/newrelic_validator"

describe "UserConfig::Validators::NewRelicValidator" do
  let(:config) { [] }
  let(:license_key_exist_validator) { m = mock(); m.stubs(:execute); m }
  let(:validator) { UserConfig::Validators::NewRelicValidator.new(license_key_exist_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should execute license_key_exist_validator" do
    license_key_exist_validator.expects(:execute)
    validator.execute(config)
  end
end