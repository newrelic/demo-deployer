require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/text/field_merger"

describe "Common::Text::FieldMerger" do
  it "should not replace anything" do
    Common::Text::FieldMerger.new().merge("anything").must_equal("anything")
  end

  it "should replace merge field" do
    merger = given_merger("[service:name1]", "http://url1/somewhere")
    replaced = merger.merge("this is the service url [service:name1] tested.")
    replaced.must_equal("this is the service url http://url1/somewhere tested.")
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

  def given_merger(key, value)
    definitions = Hash.new()
    definitions[key] = value
    return Common::Text::FieldMerger.new(definitions)
  end
  
end