require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/install/params"

describe "Common::Install::Params" do
  let(:params) { Common::Install::Params.new() }

  it "should create" do
    params.wont_be_nil
  end

  it "should update param if it exists" do
    params.add("food", "pizza")
    params.update("food", "icecream")
    params.get_all()["food"].must_equal("icecream")
  end

  it "should add param if it does not exist" do
    params.update("username", "coolperson12")
    params.get_all()["username"].must_equal("coolperson12")
  end
end
