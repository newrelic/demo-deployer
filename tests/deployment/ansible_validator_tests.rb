require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/ansible_validator"
require "./src/common/tasks/process_output"

describe "Deployment::AnsibleValidator" do
  let(:validator) { Deployment::AnsibleValidator.new() }
  let(:execution_path) {"/tmp"}

  it "should do pass validation" do
    process_output = Common::Tasks::ProcessOutput.new(0, '2.8', '', '')
    Common::Tasks::ProcessTask.any_instance.stubs(:wait_to_completion).returns(process_output)

    errors = validator.execute(execution_path)
    errors.must_be_nil
  end

  it "should pass validation without trim" do
    process_output = Common::Tasks::ProcessOutput.new(0, '2.10', '', '')
    Common::Tasks::ProcessTask.any_instance.stubs(:wait_to_completion).returns(process_output)

    errors = validator.execute(execution_path)
    errors.must_be_nil
  end

  it "should not pass validation with non zero exit code" do
    process_output = Common::Tasks::ProcessOutput.new(1, '2.8', '', '')
    Common::Tasks::ProcessTask.any_instance.stubs(:wait_to_completion).returns(process_output)

    errors = validator.execute(execution_path)
    errors.count.must_equal(1)
  end

  it "should not pass validation with no ansible version in command ouput" do
    process_output = Common::Tasks::ProcessOutput.new(0, 'no ansible verion', '', '')
    Common::Tasks::ProcessTask.any_instance.stubs(:wait_to_completion).returns(process_output)

    errors = validator.execute(execution_path)
    errors.count.must_equal(1)
  end

  it "should not pass validation when ansible version under min version" do
    process_output = Common::Tasks::ProcessOutput.new(0, '1.0', '', '')
    Common::Tasks::ProcessTask.any_instance.stubs(:wait_to_completion).returns(process_output)

    errors = validator.execute(execution_path)
    errors.count.must_equal(1)
  end
end
