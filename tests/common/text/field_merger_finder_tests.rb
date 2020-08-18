require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/text/field_merger_finder"

describe "Common::Text::FieldMergerFinder" do
  it "should not find anything" do
    Common::Text::FieldMergerFinder.new("something", "else").find("[anything]").must_be_empty()
  end

  it "should not find without bracket" do
    Common::Text::FieldMergerFinder.new("something").find("I may have something but not really because I don't have the '[' and ']' characters.").must_be_empty()
  end

  it "should find something" do
    found = Common::Text::FieldMergerFinder.new("something").find("[anything] including [something] valuable.")
    found.length.must_equal(1)
    found[0].must_equal("[something]")
  end

  it "should find something:else" do
    found = Common::Text::FieldMergerFinder.new("something", "else").find("[anything] including [something:else] valuable.")
    found.length.must_equal(1)
    found[0].must_equal("[something:else]")
  end

  it "should find any something:else" do
    found = Common::Text::FieldMergerFinder.new("something", "*").find("[anything] including [something:else] valuable.")
    found.length.must_equal(1)
    found[0].must_equal("[something:else]")
  end

  it "should find nothing" do
    found = Common::Text::FieldMergerFinder.new("*").find("There is nothing to find here.")
    found.length.must_equal(0)
  end

  it "should find anything really" do
    found = Common::Text::FieldMergerFinder.new("*").find("[anything] including valuable.")
    found.length.must_equal(1)
    found[0].must_equal("[anything]")
  end

  it "should find multiple" do
    found = Common::Text::FieldMergerFinder.new("something", "*").find("There is [something:anything] and [something:else] and both should be found.")
    found.length.must_equal(2)
    found[0].must_equal("[something:anything]")
    found[1].must_equal("[something:else]")
  end

end