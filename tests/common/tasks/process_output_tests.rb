require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/tasks/process_output"

describe "Common::Tasks::ProcessOutput" do
  it "process should succeed with short form and default" do
    process_output = given_process_output(0)
    process_output.succeeded?.must_equal(true)
  end

  it "process should succeed with default exit code of 0" do
    process_output = given_process_output(0)
    process_output.succeeded?().must_equal(true)
  end

  it "process should fail with default" do
    process_output = given_process_output(3)
    process_output.succeeded?().must_equal(false)
  end

  it "process should succeed with specific exit code value" do
    process_output = given_process_output(255)
    process_output.succeeded?(0, 255).must_equal(true)
  end

  def given_process_output(exit_code)
    return Common::Tasks::ProcessOutput.new(exit_code, nil, nil, nil)
  end
end