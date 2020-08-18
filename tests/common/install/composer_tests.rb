require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/install/composer"
require "./src/common/install/definitions/install_definition"

describe "Common::Install::Composer" do
  let(:credential) { mock(); }
  let(:provisioned_resource) { m = mock(); m.stubs(:get_credential).returns(credential);m.stubs(:get_user_name).returns("user_name");m.stubs(:get_ip).returns("1.1.1.1"); m}
  let(:install_definitions) { [] }
  let(:directory_service) { m = mock(); m.stubs(:create_sub_directory).returns("/path"); m.stubs(:get_subdirectory_paths).returns(["yaml_path/testAction"]); m }
  let(:template_merger) { m = mock(); m.stubs(:merge_template_save_file); m }
  let(:action_name) { "testAction" }
  let(:erb_path) { "erb_path" }
  let(:yaml_path) { "yaml_path" }
  let(:log_token) { m = mock(); m.stubs(:success).returns(nil); m.stubs(:error).returns(nil);  m }
  let(:roles_path) { "roles_path" }
  let(:composer) { Common::Install::Composer.new(directory_service, template_merger) }

  it "should create composer" do
    composer.wont_be_nil
  end

  describe "execute" do
    it "should do nothing" do
      composer.execute(action_name, install_definitions)
    end

    it "should do merge for all 3 templates" do
      Dir.stubs(:exist?).with("#{roles_path}/#{action_name}").returns(true)
      Dir.stubs(:exist?).with("#{yaml_path}/#{action_name}").returns(false)
      given_install_definition(provisioned_resource, erb_path, yaml_path, roles_path)
      template_merger.expects(:merge_template_save_file).times(3)
      composer.execute(action_name, install_definitions)
    end

    it "should create action sub-directory" do
      Dir.stubs(:exist?).with("#{roles_path}/#{action_name}").returns(true)
      Dir.stubs(:exist?).with("#{yaml_path}/#{action_name}").returns(false)
      given_install_definition(provisioned_resource, erb_path, yaml_path, roles_path)
      directory_service.expects(:create_sub_directory).with("#{yaml_path}/#{action_name}")
      composer.execute(action_name, install_definitions)
    end

    it "should throw when action sub-directory already exists" do
      Dir.stubs(:exist?).with("#{roles_path}/#{action_name}").returns(true)
      Dir.stubs(:exist?).with("#{yaml_path}/#{action_name}").returns(true)
      given_install_definition(provisioned_resource, erb_path, yaml_path, roles_path)
      error = assert_raises Common::InstallError do
        composer.execute(action_name, install_definitions)
      end
      error.message.must_include("Cannot generate templates for action path #{yaml_path}/#{action_name}")
    end

    def given_install_definition(provisioned_resource, erb_input_path, yaml_output_path, roles_path)
      given_logger()
      install_definition = Common::Install::Definitions::InstallDefinition.new(provisioned_resource, erb_input_path, yaml_output_path, roles_path)
      install_definitions.push(install_definition)
    end

    def given_logger()
      logger = mock()
      Common::Logger::LoggerFactory.stubs(:get_logger).returns(logger)
      logger.stubs(:debug)
    end

  end

end