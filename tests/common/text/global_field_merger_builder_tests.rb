require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/text/global_field_merger_builder"
require "./tests/context_builder"

describe "Common::Text::GlobalFieldMergerBuilder" do
  let(:context) { Tests::ContextBuilder.new().build() }

  it "should have deployment_name merge field" do
    merger = when_create()
    then_has_field(merger, "[global:deployment_name]").must_equal(true)
  end

  it "should have user_name merge field" do
    merger = when_create()
    then_has_field(merger, "[global:user_name]").must_equal(true)
  end

  it "should have deploy_name merge field" do
    merger = when_create()
    then_has_field(merger, "[global:deploy_name]").must_equal(true)
  end

  it "should have env var merge field" do
    merger = when_create()
    then_has_field(merger, "[env:*]").must_equal(true)
  end

  it "should not have invalid merge field" do
    merger = when_create()
    then_has_field(merger, "not a valid field name").must_equal(false)
  end

  def when_create()
    return Common::Text::GlobalFieldMergerBuilder.create(context)
  end

  def then_has_field(merger, field_name)
    merger.get_definitions_key().each do |key|
      if key == field_name
        return true
      end
    end
    return false
  end

end