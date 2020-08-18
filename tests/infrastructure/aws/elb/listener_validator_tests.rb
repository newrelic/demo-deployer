require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/infrastructure/aws/elb/listener_validator"

describe "Infrastructure::Aws::Elb::ListenerValidator" do
    let(:resources) { [] }
    let(:elb_max_listeners) { 5 }
    let(:validator) { Infrastructure::Aws::Elb::ListenerValidator.new(elb_max_listeners) }

    it "should create validator" do
      validator.wont_be_nil
    end

    it "should allow up to max number of listeners" do
      given_resource("elb1", [*('a'..'e')])
      validator.execute(resources).must_be_nil()
    end

    it "should not allow more than maximum number of listeners" do
      given_resource("elb1", [*('a'..'z')])
      result = validator.execute(resources)
      result.wont_be_nil()
      result.must_include(elb_max_listeners.to_s)
    end

    def given_resource(id, listeners)
      resources.push({"id"=> id, "listeners"=> listeners})
    end
end