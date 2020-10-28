require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/user_config/definitions/credential"

describe "UserConfig::Definitions::Credential" do
  let(:credential) { UserConfig::Definitions::Credential.new("test", nil) }

  it "add_if_exists should default to adding the prefix" do
    items = {}
    credential.add_if_exist(items, "key", "value")
    items["test_key"].must_equal("value")
    items["key"].must_be_nil()
  end

  it "add_if_exists should not add prefix" do
    items = {}
    credential.add_if_exist(items, "key", "value", true)
    items["test_key"].must_be_nil()
    items["key"].must_equal("value")
  end
end

