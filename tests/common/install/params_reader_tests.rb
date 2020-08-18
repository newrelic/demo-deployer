require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/install/params"
require "./src/common/install/params_reader"

describe "Common::Install::ParamsReader" do
  let(:params) { Common::Install::Params.new() }
  let(:content) { {} }
  let(:reader) { Common::Install::ParamsReader.new(params) }

  it "should create" do
    reader.wont_be_nil
  end

  it "should read single param" do
    given_param("fruit", "apple")
    reader.read_from_json(get_json_content())
    params.get_all()["fruit"].must_equal("apple")
  end

  it "should read multiple param" do
    given_param("fruit", "apple")
    given_param("drink", "lacroix")
    reader.read_from_json(get_json_content())
    params.get_all()["fruit"].must_equal("apple")
    params.get_all()["drink"].must_equal("lacroix")
  end

  it "should not overwrite param" do
    given_param("fruit", "apple")
    reader.read_from_json(get_json_content())
    given_param("fruit", "peach")
    error = assert_raises RuntimeError do
      reader.read_from_json(get_json_content())
    end
    error.message.must_include("overwrite")
    error.message.must_include("fruit")
    error.message.must_include("apple")
    error.message.must_include("peach")
  end

  it "should not throw when attempting to override with same value" do
    given_param("fruit", "apple")
    reader.read_from_json(get_json_content())
    reader.read_from_json(get_json_content())
    params.get_all()["fruit"].must_equal("apple")
  end

  it "should not modify underlying param data" do
    given_param("fruit", "apple")
    reader.read_from_json(get_json_content())
    params.get_all()["fruit"] = "peach"
    params.get_all()["fruit"].must_equal("apple")
  end

  def given_param(key, value)
    json_params = content["params"] || {}
    json_params[key] = value
    content["params"] = json_params
  end

  def get_json_content()
    return content.to_json()
  end

end