require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/provision/provider"
require "./src/infrastructure/definitions/resource_data"

describe "Provision::Provider" do
    let(:provision_group) { 1 }
    let(:valid_host) { "host1"}
    let(:invalid_host) { "host3" }
    let(:resource1) { Infrastructure::Definitions::ResourceData.new(valid_host, "gws", provision_group) }

    let(:infrastructure_provider) { m = mock(); m.stubs(:get_all).returns([resource1]); m }
    let(:provider) { Provision::Provider.new(infrastructure_provider) }

  it "should create providerr" do
    provider.wont_be_nil
  end

  describe "get_by_id" do
    it "should" do
      result = provider.get_by_id(valid_host)
      result.get_id().must_equal(valid_host)
    end

    it "should not" do
      result = provider.get_by_id(invalid_host)
      result.must_be_nil()
    end
  end

end