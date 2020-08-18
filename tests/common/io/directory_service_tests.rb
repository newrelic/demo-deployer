require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/io/directory_service"

describe "Common::Io::TemporaryDirectoryService" do
  let(:service) { Common::Io::DirectoryService.new("/tmp") }

  before do
    FileUtils.stubs(:remove_dir)
    FileUtils.stubs(:mkdir_p)
  end

  it "should create service" do
    service.wont_be_nil
  end

  it "should combine directory path as-is" do
    result = service.get_subdirectory_paths("testing")
    result.must_equal(["/tmp/testing"])
  end
  
  it "should combine directory path as-is" do
    result = Common::Io::DirectoryService.combine_paths("/root", "testing")
    result.must_equal("/root/testing")
  end
  
  it "should combine directory path and remove leading slash on concatenated part" do
    result = Common::Io::DirectoryService.combine_paths("/root", "/testing")
    result.must_equal("/root/testing")
  end
  
  it "should combine directory path with multiple parts" do
    result = Common::Io::DirectoryService.combine_paths("/root", "grand", "parent", "child")
    result.must_equal("/root/grand/parent/child")
  end

  it "should combine multiple sub-directory path as-is" do
    result = service.get_subdirectory_paths("dir1/subdir2/xx/yy")
    result.must_equal(["/tmp/dir1", "/tmp/dir1/subdir2", "/tmp/dir1/subdir2/xx", "/tmp/dir1/subdir2/xx/yy"])
  end

  it "should combine directory path and removing leading slash" do
    result = service.get_subdirectory_paths("/testing")
    result.must_equal(["/tmp/testing"])
  end
  
  it "should combine directory path and removing all leading slash" do
    result = service.get_subdirectory_paths("///testing")
    result.must_equal(["/tmp/testing"])
  end

end