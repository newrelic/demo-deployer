require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/io/file_writer"

describe "Common::Io::FileWriter" do
  let(:contents) {"contents"}
  let(:service) { Common::Io::FileWriter.new("tmp", contents) }
  
  it "should create service" do
    service.wont_be_nil
  end

  it "should call write" do 
    file = mock()
    File.expects(:open).returns(file)
    file.expects(:write)
    file.expects(:close)
    service.execute
  end
end