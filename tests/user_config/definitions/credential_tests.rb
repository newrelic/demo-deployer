require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/user_config/definitions/credential"

describe "UserConfig::Definitions::Credential" do
  let(:items) { {} }
  let(:query_lambda) { lambda { |path| return items[path] } }
  let(:envs) { {} }
  let(:ssm_param) { {} }
  let(:env_lambda) { lambda { |name| return envs[name] } }
  let(:ssm_param_lambda) { lambda { |name| return ssm_param[name] } }
  let(:credential) { UserConfig::Definitions::Credential.new("test", query_lambda, env_lambda, ssm_param_lambda) }

  it "add_if_exists should apply prefix if it exists" do
    credential.add_if_exist(items, "key", "value", "test")
    items["test_key"].must_equal("value")
    items["key"].must_be_nil()
  end

  it "add_if_exists should not apply prefix if it does not exit" do
    credential.add_if_exist(items, "key", "value", nil)
    items["test_key"].must_be_nil()
    items["key"].must_equal("value")
  end

  it "should retrieve single item" do
    credential.add_if_exist(items, "key", "value")
    credential.query("key").must_equal("value")
  end

  it "should query without env var" do
    credential.add_if_exist(items, "key", "value")
    credential.query("key").must_equal("value")
  end

  it "should query with env var" do
    envs["my_var"] = "my_env_value"
    credential.add_if_exist(items, "key", "[env:my_var]")
    credential.query("key").must_equal("my_env_value")
  end
  
  it "should query with env var case insensitive" do
    envs["my_var"] = "my_env_value"
    credential.add_if_exist(items, "key", "[eNv:my_var]")
    credential.query("key").must_equal("my_env_value")
  end

  it "should query with env var missing" do
    credential.add_if_exist(items, "key", "[env:my_var]")
    credential.query("key").must_be_nil()
  end

  it "should not match env var" do
    envs["my_var"] = "my_env_value"
    credential.add_if_exist(items, "key", "[not_env:my_var]")
    credential.query("key").must_equal("[not_env:my_var]")
  end

  it "should identify ssm param name" do
    ssm_param["/namespace/path1/key2"] = "my_env_value"
    credential.add_if_exist(items, "key", "[aws_ssm_param:/namespace/path1/key2]")
    credential.query("key").must_equal("my_env_value")
  end

end
