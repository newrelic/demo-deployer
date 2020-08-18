require "./src/orchestrator"
require "./src/context"
require "./user_acceptance_tests/spoofers/deployment_directory_spoofer"
require "./user_acceptance_tests/spoofers/test_spoofers"
require "./user_acceptance_tests/file_finder"

class DeploymentManager
  attr_reader :context
  
  def initialize(config_filename, test_directory)
    @command_line_arguments = ["-l", "error"]
    @user_config_filename = "uatuser.json"
    @context = Context.new()
    @orchestrator = Orchestrator.new(@context)
    @deploy_config_filename = config_filename
    @test_directory = test_directory
    @spoofers = UserAcceptanceTests::Spoofers::TestSpoofers.new([])
  end

  def deploy() 
    skip = given_template_config_files(@test_directory)
    if skip 
      raise "Unable to load provided config file"
    end

    summary = @orchestrator.execute(@command_line_arguments)
    summary.must_include("Deployment successful")
  end

  def teardown()
    given_teardown_configured()
    summary = @orchestrator.execute(@command_line_arguments)
    summary.must_include("Teardown successful")
  end

  def after_each()
    spoofer = UserAcceptanceTests::Spoofers::DeploymentDirectorySpoofer.new(@user_config_filename, @deploy_config_filename)
    app_config_provider = @context.get_app_config_provider()
    if (app_config_provider != nil)
      path = @context.get_app_config_provider().get_execution_path()
      spoofer.set_directory_path(path)
    end
    @spoofers.add(spoofer)
    @spoofers.dispose()
  end

  def given_template_config_files(directory_path)
    @command_line_arguments.push("-c")
    local_user_filename = "#{@user_config_filename}.local"
    local_user_filepath = UserAcceptanceTests::FileFinder.find_up(local_user_filename, directory_path)
    if local_user_filepath != nil && File.exist?(local_user_filepath)
      @command_line_arguments.push(local_user_filepath)
    else
      puts "HappyPath tests is skipped. A #{local_user_filename} file is required in order to provision the resources but was not found in the current directory structure or parents."
      return true
    end
    @command_line_arguments.push("-d")
    @command_line_arguments.push("#{directory_path}/#{@deploy_config_filename}")
    return false
  end

  def given_teardown_configured()
    @command_line_arguments.push("-t")
  end
end
