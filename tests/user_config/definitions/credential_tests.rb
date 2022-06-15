require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/user_config/definitions/credential"

describe "UserConfig::Definitions::Credential" do
  let(:items) { {} }
  let(:query_lambda) { lambda { |path| return items[path] } }
  let(:envs) { {} }
  let(:env_lambda) { lambda { |name| return envs[name] } }
  let(:credential) { UserConfig::Definitions::Credential.new("test", query_lambda, env_lambda) }

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

  it "should identify env var" do
    credential.get_matching_env_or_nil("[env:my_var]").must_equal("my_var")
  end

  it "should identify env var case insensitive" do
    credential.get_matching_env_or_nil("[eNv:my_var]").must_equal("my_var")
  end

  it "should NOT identify env var" do
    credential.get_matching_env_or_nil("ABC!@#").must_be_nil()
  end

  it "should NOT identify env var when no env" do
    credential.get_matching_env_or_nil("[not_env:my_var]").must_be_nil()
  end

  it "should query without env var" do
    credential.add_if_exist(items, "key", "value")
    credential.query("key").must_equal("value")
  end

  it "should query without env var" do
    envs["my_var"] = "my_env_value"
    credential.add_if_exist(items, "key", "[env:my_var]")
    credential.query("key").must_equal("my_env_value")
  end

end

