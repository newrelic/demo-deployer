require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/text/field_merger"

describe "Common::Text::FieldMerger" do
  let(:env_vars)  {Hash.new()}
  let(:env_lambda) { lambda { |name| return env_vars[name] } }
  
  it "should not replace anything" do
    Common::Text::FieldMerger.new().merge("anything").must_equal("anything")
  end

  it "should replace merge field" do
    merger = given_merger("[service:name1]", "http://url1/somewhere")
    replaced = merger.merge("this is the service url [service:name1] tested.")
    replaced.must_equal("this is the service url http://url1/somewhere tested.")
  end
  
  it "should replace environment variable field" do
    merger = given_merger("[env:*]","")
    given_env_var("MY_TEAM_VAR", "teamX")
    replaced = merger.merge("this is my team name [env:MY_TEAM_VAR].")
    replaced.must_equal("this is my team name teamX.")
  end

  it "should replace all environment variable fields" do
    merger = given_merger("[env:*]","")
    given_env_var("MY_VAR1", "team1")
    given_env_var("MY_VAR2", "team2")
    replaced = merger.merge("this is my team name [env:MY_VAR1] and [env:MY_VAR2].")
    replaced.must_equal("this is my team name team1 and team2.")
  end

  it "should replace all merge fields" do
    merger = given_merger("[service:name1]", "http://url1/somewhere")
    replaced = merger.merge("[service:name1] and [service:name1] are all urls.")
    replaced.must_equal("http://url1/somewhere and http://url1/somewhere are all urls.")
  end

  it "should not replace anything when not found" do
    merger = given_merger("[service:name1]", "http://url1/somewhere")
    merger.merge("anything").must_equal("anything")
  end

  it "should not replace values when nil" do
    merger = given_merger("[resource:host1:private_dns_name]", nil)
    dictionary = {
      "key1": "This is the dns [resource:host1:private_dns_name] value."
    }
    merger.merge_values(dictionary).must_equal(dictionary)
  end

  def given_merger(key, value)
    definitions = Hash.new()
    definitions[key] = value
    return Common::Text::FieldMerger.new(definitions, env_lambda)
  end

  def given_env_var(key, value)
    env_vars[key] = value
  end
  
end