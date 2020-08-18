require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/type_repository"

describe "Common::TypeRepository" do
  let(:gcp_type) { m = mock(); m }
  let(:aws_type) { m = mock(); m }
  let(:default_type) { m = mock(); m }
  let(:supported_types) { { "aws" => aws_type, "gcp" => gcp_type } }
  let(:repository) { Common::TypeRepository.new(
      supported_types,
      lambda { |element| element.get_id() }
      ) }

  it "should create repository" do
    repository.wont_be_nil
  end

  it "should lookup supported type" do
    element = given_element("aws")
    type = repository.get(element)
    type.must_equal(aws_type)
  end

  it "should error when looking up with undefined key" do
    element = given_element(nil)
    error = assert_raises do
      repository.get(element)
    end
    error.message.must_include("Missing key")
    error.message.must_include("aws")
  end

  it "should error when looking up unsupported type" do
    element = given_element("unk")
    error = assert_raises do
      repository.get(element)
    end
    error.message.must_include("is not currently supported")
    error.message.must_include("aws")
  end

  it "should return default when looking up unsupported type" do
    element = given_element("unk")
    repository_with_default = Common::TypeRepository.new(
      supported_types,
      lambda { |element| element.get_id() },
      lambda { return default_type }
      )
    type = repository_with_default.get(element)
    type.must_equal(default_type)
  end

  def given_element(id)
    element = mock()
    element.stubs(:get_id).returns(id)
    return element
  end
end