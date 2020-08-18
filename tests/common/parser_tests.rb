require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/json_parser"

describe "Common::JsonParser" do
  let(:parser) { Common::JsonParser.new() }

  it "should return an empty array when File is nil" do
      parser.get_children(nil, "resources").must_be_empty()
  end

  it "should return the contents of the 'resources' array object" do
    config_file = '{"resources":[{"id":"host1"}]}'
    parser.get_children(config_file, "resources").must_equal([{"id"=>"host1"}])
  end

  it "should return an empty array 'resources' array object" do
    config_file = '{"resources":[]}'
    parser.get_children(config_file, "resources").must_equal([])
  end
  
  it "should return an empty array when key is not present" do
    config_file = '{"resources":[]}'
    parser.get_children(config_file, "services").must_equal([])
  end
end