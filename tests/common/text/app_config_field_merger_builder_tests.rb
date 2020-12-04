require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/text/app_config_field_merger_builder"
require "./src/user_config/definitions/new_relic_credential"
require "./src/user_config/credential_factory"
require "./tests/context_builder"

describe "Common::Text::AppConfigFieldMergerBuilder" do
  let(:new_relic_urls) { {} }
  let(:nr_user_config) { {} }
  let(:context) { Tests::ContextBuilder.new() }
  let(:builder) { Common::Text::AppConfigFieldMergerBuilder.new() }
  let(:newrelic_credentials) { UserConfig::Definitions::NewRelicCredential.new("newrelic", UserConfig::CredentialFactory.get_credential_query_lambda(nr_user_config)) }


  it "should build empty" do
    builder.build().wont_be_nil()
  end

  it "should build app config url" do
    given_new_relic_url("us", "test_url", "test.com")
    con = given_context(new_relic_urls)
    
    fields = builder.with_new_relic_urls(con).build()
    fields.get_definitions_key().must_include("[app_config:newrelic:test_url]")
  end

  it "should default to U.S. urls" do
    given_new_relic_url("us", "test_url", "test.com")
    given_new_relic_url("staging", "test_url", "staging-test.com")
    con = given_context(new_relic_urls)

    fields = builder.with_new_relic_urls(con).build()
    fields.merge("[app_config:newrelic:test_url]").must_equal("test.com")  
  end

  it "should change url based on user configuration region" do
    given_new_relic_url("us", "test_url", "test.com")
    given_new_relic_url("staging", "test_url", "staging-test.com")
    given_user_config_region("staging")
    con = given_context(new_relic_urls)

    fields = builder.with_new_relic_urls(con).build()
    fields.merge("[app_config:newrelic:test_url]").must_equal("staging-test.com")  
  end

  it "should be case insensitive for region" do
    given_new_relic_url("us", "test_url", "test.com")
    given_user_config_region("US")
    con = given_context(new_relic_urls)

    fields = builder.with_new_relic_urls(con).build()
    fields.merge("[app_config:newrelic:test_url]").must_equal("test.com")  
  end
  

  def given_new_relic_url(region, name, value)
    if new_relic_urls[region].nil?
      new_relic_urls[region] = {}
    end
    new_relic_urls[region][name] = value
  end

  def given_user_config_region(region)
    context.user_config().with_credentials("newrelic", { "nrRegion" => region })
  end

  def given_context(urls)
    context.app_config().with("newRelicUrls", new_relic_urls)
    return context.build()
  end
end
