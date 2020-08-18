require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/provider"

describe "Deployment::Provider" do
  let(:context) { mock() }
  let(:provider) { Deployment::Provider.new(context) }

  it "should create provider" do
    provider.wont_be_nil
  end    
  
end