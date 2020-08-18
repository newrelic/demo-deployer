require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/io/directory_copier"

describe "Common::Io::DirectoryCopier" do
  let(:service) { Common::Io::DirectoryCopier.new() }
  
  before do
    FileUtils.stubs(:mkdir_p)
    FileUtils.stubs(:cp_r)
  end

  it "should create service" do
    service.wont_be_nil
  end

  it "creates destination directory if it does not exist" do
    File.stubs(:exist?).returns(false)
    FileUtils.expects(:mkdir_p).once
    service.copy("/test/dir", "/new/test")
  end

  it "does not create destination directory if it exists" do
    File.stubs(:exist?).returns(true)
    FileUtils.expects(:mkdir_p).never
    service.copy("/test/dir", "/new/test")
  end

  it "returns full path to the copied directory" do
    File.stubs(:exist?).returns(true)
    new_path = service.copy("/test/dir", "/new/test")
    new_path.must_equal("/new/test/dir")
  end 

end