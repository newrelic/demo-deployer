require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/text/field_merger"
require "./src/common/text/field_merger_builder"

describe "Common::Text::FieldMergerBuilder" do
  let(:builder)  { Common::Text::FieldMergerBuilder.new() }

  it "should build empty" do
    builder.build().wont_be_nil
  end

  it "should build single field definition" do
    merger = given_definition(["service1"], "url1").build()

    merger.merge("a string with [service1] in it.")
      .must_equal("a string with url1 in it.")
  end

  it "should build single field definition with multiple key part" do
    merger = given_definition(["service:name1"], "url1").build()

    merger.merge("a string with [service:name1] in it.")
      .must_equal("a string with url1 in it.")
  end
  
  it "should build multiple field definitions" do
    merger = given_definition(["service:name1"], "url1")
      .given_definition(["service:name2"], "url2")
      .given_definition(["service:name3"], "url3")
      .build()

    merger.merge("a string with [service:name2] in it.")
      .must_equal("a string with url2 in it.")
  end

  def given_definition(parts, value)
    builder.create_definition(parts, value)
    return self
  end

  def build()
    return builder.build()
  end
end