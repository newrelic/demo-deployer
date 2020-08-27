require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "./tests/context_builder.rb"

require "./src/infrastructure/aws/ec2/pem_key_validator"

describe "Infrastructure::Aws::Ec2::PemKeyValidator" do
  let(:pem_key_path) { "/pem/key/path/pem.pem" }
  let(:context){ Tests::ContextBuilder.new()
    .user_config().with_aws()
    .build() }
  let(:secret_key_path_exisits_validator) { m = mock(); m.stubs(:execute); m }
  let(:secret_key_path_file_validator) { m = mock(); m.stubs(:execute); m }
  let(:pem_key_permission_validator) { m = mock(); m.stubs(:execute); m }

  let(:validator) { Infrastructure::Aws::Ec2::PemKeyValidator.new(context,secret_key_path_exisits_validator,secret_key_path_file_validator,pem_key_permission_validator) }

  it "should create validator" do
    _(validator).wont_be_nil()
  end

  it "should invoke key path exists validator" do
    secret_key_path_exisits_validator.expects(:execute)
    validator.execute()
  end

  it "should invoke key path file validator" do
    secret_key_path_file_validator.expects(:execute)
    validator.execute()
  end

  it "should invoke key permission validator" do
    pem_key_permission_validator.expects(:execute)
    validator.execute()
  end

end