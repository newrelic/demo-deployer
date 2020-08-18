require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/validators/size_validator"

describe "Common::Validators::SizeValidator" do
  let(:resources) { [] }
  let(:supported_size) { ["verysmall", "huge"] }
  let(:validator) { Common::Validators::SizeValidator.new(supported_size) }
  
  it "should create validator" do
    validator.wont_be_nil
  end

  it "should allow supported size" do
    given_resource("host1", "huge")
    validator.execute(resources).must_be_nil()
  end
  
  it "should not allow unsupported size" do
    given_resource("host1", "infinity")
    result = validator.execute(resources)
    result.wont_be_nil()
    result.must_include("infinity")
  end

  def given_resource(id, size)
    resources.push({"id"=> id, "size"=> size})
  end
end
