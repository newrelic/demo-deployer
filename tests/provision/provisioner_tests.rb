require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/validation_error"
require "./src/provision/provisioner"
require "./src/infrastructure/definitions/resource_data"

describe "Provision::Provisioner" do
  let(:error)       { ["ERROR!!!"] }
  let(:no_errors)       { [] }
  let(:player)          { m = mock(); m.stubs(:stack); m }
  let(:provisioner)     { Provision::Provisioner.new(lambda {return player}) }
  let(:template_contexts)   { [] }

  before do
    File.stubs(:directory?).returns(true)
  end

  it "should create provisioner" do
    expect(provisioner).wont_be_nil
  end

  describe "execute" do
    it 'should raise validation error' do
      given_template_context("/script_path", "/execution_path")
      given_player_returns(error)

      assert_raises Common::ValidationError do
        provisioner.execute(template_contexts)
      end
    end

    it "should execute script" do
      given_template_context("/script_path", "/execution_path")
      given_player_stack()
      given_player_returns(no_errors).once
      provisioner.execute(template_contexts)
    end

    it "should execute script twice" do
      given_template_context("/script_path", "/execution_path")
      given_template_context("/another_script_path", "/execution_path")
      given_player_stack().twice
      given_player_returns(no_errors).once
      provisioner.execute(template_contexts)
    end
  end

  def given_template_context(script_path, execution_path)
    template_context = mock()
    template_context.stubs(:get_template_output_file_path).returns(script_path)
    template_context.stubs(:get_execution_path).returns(execution_path)
    resource = given_resource("resource_id")
    template_context.stubs(:get_resource).returns(resource)
    template_contexts.push(template_context)
  end

  def given_resource(id)
    return Infrastructure::Definitions::ResourceData.new(id, "any", 0)
  end

  def given_player_returns(output)
    return player.expects(:execute).returns(output)
  end
  
  def given_player_stack()
    return player.expects(:stack)
  end
end