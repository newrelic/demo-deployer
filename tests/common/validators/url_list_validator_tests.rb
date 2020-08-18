require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/url_list_validator"

describe "Common::Validators::UrlListValidator" do
  let(:items) { [] }
  let(:error_message) { "there was a significant error while running a test" }
  let(:url_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:validator) { Common::Validators::UrlListValidator.new("url", error_message, url_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should not error when not provided" do
    given_item("ip", "1.1.1.1")
    validator.execute(items).must_be_nil()
  end

  it "should not allow empty" do
    given_item("url", "")
    url_validator.stubs(:execute).returns("nope")
    validator.execute(items).must_include(error_message)
  end

  it "should not allow non url" do
    given_item("url", "this is not a valid url")
    url_validator.expects(:execute).returns("nope")
    validator.execute(items).must_include(error_message)
  end

  it "should not error when no elements" do
    validator.execute(nil).must_be_nil()
  end

  it "should allow no elements" do
    validator.execute(items).must_be_nil()
  end

  it "should allow string" do
    given_item("url", "http://somewhere.newrelic.com")
    given_item("url", "http://somewhereelse.newrelic.com")
    validator.execute(items).must_be_nil()
  end
  
  def given_item(key, value)
    if key.nil? == false
      items.push({key=> value})
    else
      items.push({})
    end
  end
end