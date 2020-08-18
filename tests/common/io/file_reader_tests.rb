require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/io/file_reader"

describe "Common::Io::FileReader" do
  let(:error_msg) {"error"}
  let(:service) { Common::Io::FileReader.new("tmp", error_msg) }
  
  it "should create service" do
    service.wont_be_nil
  end

  it "should call read" do 
    file = mock()
    File.expects(:read)
    service.execute
  end
end