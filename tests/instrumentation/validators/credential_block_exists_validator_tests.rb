require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "json"

require "./src/instrumentation/validators/credential_block_exists_validator"
require "./tests/context_builder"

describe "Instrumentation::Validators::CredentialBlockExistsValidator" do
  let(:instrumentors) { [] }
  let(:context_builder){ Tests::ContextBuilder.new().user_config().with_new_relic() }

  it "should create validator" do
    get_validator().wont_be_nil()
  end

  it "should not error when no instrumentors" do
    validator_execute().must_be_nil()
  end

  it "should not error when no provider" do
    given_instrumentor(nil)
    validator_execute().must_be_nil()
  end

  it "should error when credential is not supported" do
    given_instrumentor("datarelic")
    given_credential("datarelic")
    validator_execute().must_include("datarelic")
  end

  it "should error when provider credential block missing" do
    given_instrumentor("datarelic")
    given_credential("gcp")
    validator_execute().must_include("datarelic")

    given_instrumentor("datarelic")
    validator_execute().must_include("datarelic")
  end

  it "should error for each instrumentor missing credentials" do
    given_instrumentor("newpup")
    given_credential("newpup")
    given_instrumentor("datarelic")
    given_instrumentor("oversight")

    result = validator_execute()
    result.must_include("datarelic")
    result.must_include("oversight")
  end

  def given_instrumentor(provider = nil)
    instrumentor = {}
    unless provider.nil?()
      instrumentor["provider"] = provider
    end
    instrumentors.push(JSON.parse(instrumentor.to_json()))
  end

  def given_credential(provider)
    context_builder.user_config().with_credentials(provider, {})
  end

  def validator_execute()
    return get_validator().execute(instrumentors)
  end

  def get_validator()
    context = context_builder.build()
    validator =  Instrumentation::Validators::CredentialBlockExistsValidator.new(context.get_user_config_provider())
  end

end