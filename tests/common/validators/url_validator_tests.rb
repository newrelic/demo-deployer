require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/url_validator"

describe "Common::Validators::UrlValidator" do
  let(:error_message) { "'service X' url is not valid" }
  let(:validator) { Common::Validators::UrlValidator.new(error_message) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should return nil for valid http url" do
    url = "http://www.example.com"
    validator.execute(url).must_be_nil
  end

  it "should return nil for valid https url" do
    url = "https://www.example.com"
    validator.execute(url).must_be_nil
  end

  it "should return error message for nil" do
    url = nil
    validator.execute(url).must_include(error_message)
  end

  it "should return error message empty string" do
    url = ""
    validator.execute(url).must_equal(error_message)
  end

  it "should return error message for invalid protocol url" do
    url = "htt://www.example.com"
    validator.execute(url).must_equal(error_message)
  end

  it "should return error message for malformed domain name" do
    url = "http://www.examp le.com/"
    validator.execute(url).must_include(error_message)
  end

end