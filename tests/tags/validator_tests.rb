require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "./src/tags/validator"

describe "Tags::Validator::execute" do
  let(:tags) { {} }
  let(:tag_character_validator) { m = mock(); m.stubs(:execute); m }
  let(:tag_length_validator) { m = mock(); m.stubs(:execute); m }
  let(:validator) { Tags::Validator.new(tag_length_validator,tag_character_validator)}

   it "should create validator" do
    validator.wont_be_nil
  end

  it "should validate tag characters are supported" do
    tag_character_validator.expects(:execute)
    validator.execute(tags)
  end

  it "should validate length of tag keys and values" do
    tag_length_validator.expects(:execute)
    validator.execute(tags)
  end

end