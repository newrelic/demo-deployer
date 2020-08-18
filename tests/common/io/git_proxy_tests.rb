require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/io/git_proxy"
require "./src/common/tasks/process_output"
require "./src/common/tasks/process_task"
require "./src/common/validation_error"
require "./tests/context_builder"

describe "Common::Io::GitProxy" do
  describe "execute" do
  
  let(:command) {"clone"}
  let(:git_credentials) { {} }
  let(:context){ Tests::ContextBuilder.new().user_config().with_git_credential("myusername", "ABC123").build() }
  let(:proxy) { Common::Io::GitProxy.new(context) }
  let(:project_name) { "project_name" }
  let(:source_repository) { "something:something/#{project_name}.git" }
  let(:destination_path) { "/destination_path" }
  let(:path_to_source) { "/destination_path/project_name"}

  before do
    FileUtils.stubs(:mkdir_p)
  end
 
  it "should create git proxy" do
    proxy.wont_be_nil
  end

  it "should return path_to_source when no errors" do
    process_output = Common::Tasks::ProcessOutput.new(0, 'output', '', '')
    Common::Tasks::ProcessTask.any_instance.stubs(:wait_to_completion).returns(process_output)
    expect(proxy.clone(source_repository, destination_path)).must_equal(path_to_source)
  end

  it "should raise an error when non-zero exit code" do
    process_output = Common::Tasks::ProcessOutput.new(1, 'bad output', '', '')
    Common::Tasks::ProcessTask.any_instance.stubs(:wait_to_completion).returns(process_output)
    assert_raises Common::ValidationError do
       proxy.clone(source_repository, destination_path)
    end
  end

  it "should replace git credential" do
    source_repository = "https://[credential:git:myusername]@newrelicgit.com/awesometeam/#{project_name}.git"
    git_credentials["myusername"] = "ABC123"
    process_output = Common::Tasks::ProcessOutput.new(0, 'output', '', '')
    Common::Tasks::ProcessTask.any_instance.stubs(:wait_to_completion).returns(process_output)
    expected_process_command = "https://myusername:ABC123@newrelicgit.com/awesometeam/#{project_name}.git"
    expect(proxy.clone(expected_process_command, destination_path)).must_equal(path_to_source)    
  end

 end
end
