require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "./tests/context_builder.rb"

require "./src/infrastructure/aws/ec2/pem_key_permission_validator"

describe "Infrastructure::Aws::Ec2::PemKeyPermissionValidator" do
  let(:context){ Tests::ContextBuilder.new()
    .user_config().with_aws()
    .build() }
  let(:pem_key_path) { "/pem/key/path/pem.pem" }
  let(:validator) { Infrastructure::Aws::EC2::PemKeyPermissionValidator.new(context) }

  let(:valid_pem_base_8_permission)   { "100400".to_i(8) }
  let(:invalid_pem_base_8_permission) { "100401".to_i(8) }

  it "should create validator" do
    _(validator).wont_be_nil()
  end

  it "should find pem key permission valid" do
    @mock_file = Minitest::Mock.new
    @mock_file.expect(:mode, valid_pem_base_8_permission)

    File.stub :stat, @mock_file do
      _(validator.execute()).must_be_nil
    end
  end

  it "should find pem key permission invalid" do
    @mock_file = Minitest::Mock.new
    @mock_file.expect(:mode, invalid_pem_base_8_permission)

    File.stub :stat, @mock_file do
      _(validator.execute()).wont_be_nil
    end
  end

end