require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/infrastructure/definitions/aws/ec2_resource"
require "./src/infrastructure/definitions/aws/elb_resource"
require "./src/deployment/listeners_validator"
require './src/infrastructure/definitions/aws/elb_resource'

describe "Deployment::ListenersValidator" do
  let(:resources) { [] }
  let(:validator) { Deployment::ListenersValidator.new(Infrastructure::Definitions::Aws::ElbResource) }

  it "should not error when no resources or services defined" do
    validator.execute(resources).must_be_nil()
  end

  it "should not error if no resources with search_value" do
    resources.push(given_ec2_resource())
    validator.execute(resources).must_be_nil()
  end

  it "should not error if resource includes search_value and dependency exists" do
    resources.push(given_elb_resource())
    validator.execute(resources).must_be_nil()
  end

  it "should error if resource includes search value and dependency doesn't exist" do
    resources.push(given_elb_resource('app_elb', nil))
    error = validator.execute(resources)
    error.must_include('app_elb')
  end

  it "should error if resource includes search value and dependency is empty" do
    resources.push(given_elb_resource('app_elb', []))
    error = validator.execute(resources)
    error.must_include('app_elb')
  end

  it "should error twice if two resources include search value and dependency doesn't exist" do
    resources.push(given_elb_resource('app_elb1', nil))
    resources.push(given_elb_resource('app_elb2', nil))

    error = validator.execute(resources)
    error.must_include('app_elb1')
    error.must_include('app_elb2')
  end


  def given_elb_resource(id = 'app_elb', listeners = ['app1'])
    credential = 'XXX'
    user_name = 'username'

    resource = Infrastructure::Definitions::Aws::ElbResource.new(id, credential, listeners, user_name, [])
    return resource
  end

  def given_ec2_resource()
    id = 'host1'
    credential = 'XXX'
    size = 'micro'
    user_name = 'ec2-user'

    resource = Infrastructure::Definitions::Aws::Ec2Resource.new(id, credential, size, user_name, [])
    return resource
  end

end