require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/install/composer"
require "./src/common/install/definitions/install_definition"

describe "Common::Install::Installer" do
  let(:install_definitions) { [] }
  let(:directory_service) { m = mock(); m.stubs(:create_sub_directory).returns("/path"); m }
  let(:composer) { m = mock(); m.stubs(:execute); m }
  let(:installer) { Common::Install::Installer.new(directory_service, nil, composer) }

  it "should create composer" do
    composer.wont_be_nil
  end

  describe "execute" do
    it "should do nothing" do
      installer.execute(install_definitions)
    end

    it "should do call install method" do
      installer.queue_step("parallel_step")
      installer.expects(:install).times(1)
      installer.execute(install_definitions)
    end

    it "should do call install_serially_per_host method" do
      installer.queue_step("serial_step", true)
      installer.expects(:install_serially_per_host).times(1)
      installer.execute(install_definitions)
    end

  end

end