require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/io/yaml_file_loader"

describe "Common::Io::YamlFileLoader" do
  let(:error_msg) {"error"}
  let(:service) { Common::Io::YamlFileLoader.new("tmp", error_msg) }

  it "should create service" do
    service.wont_be_nil
  end

  it "should call YAML.load(File.read(@filepath))" do
    YAML.expects(:load).returns({})
    File.expects(:read)
    service.execute
  end
end