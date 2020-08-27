require "./src/context"
require_relative "command_line/command_line_provider_builder"
require_relative "app_config/app_config_provider_builder"
require_relative "user_config/user_config_provider_builder"
require_relative "tags/tags_provider_builder"
require_relative "infrastructure/infrastructure_provider_builder"
require_relative "services/services_provider_builder"
require_relative "instrumentation/instrumentation_provider_builder"
require_relative "provision/provision_provider_builder"

module Tests
  class ContextBuilder

    def initialize()
      @context = nil
      @command_line_provider_builder = Tests::CommandLine::CommandLineProviderBuilder.new(self)
      @app_config_provider_builder = Tests::AppConfig::AppConfigProviderBuilder.new(self)
      @user_config_provider_builder = Tests::UserConfig::UserConfigProviderBuilder.new(self)
      @tags_provider_builder = Tests::Tags::TagsProviderBuilder.new(self)
      @infrastructure_provider_builder = Tests::Infrastructure::InfrastructureProviderBuilder.new(self)
      @services_provider_builder = Tests::Services::ServicesProviderBuilder.new(self)
      @instrumentation_provider_builder = Tests::Instrumentation::InstrumentationProviderBuilder.new(self)
      @provision_provider_builder = Tests::Provision::ProvisionProviderBuilder.new(self)
      # Defaulting
      @command_line_provider_builder.user_config("user.json")
      @command_line_provider_builder.deploy_config("deploy.json")
    end

    def command_line()
      return @command_line_provider_builder
    end

    def app_config()
      return @app_config_provider_builder
    end

    def user_config()
      return @user_config_provider_builder
    end

    def tags()
      return @tags_provider_builder
    end

    def infrastructure()
      return @infrastructure_provider_builder
    end

    def services()
      return @services_provider_builder
    end

    def instrumentations()
      return @instrumentation_provider_builder
    end

    def provision()
      return @provision_provider_builder
    end

    def build()
      return @context ||= createInstance()
    end

    private
    def createInstance()
      context = Context.new()
      @command_line_provider_builder.build(context)
      @app_config_provider_builder.build(context)
      @user_config_provider_builder.build(context)
      @tags_provider_builder.build(context)
      @infrastructure_provider_builder.build(context)
      @services_provider_builder.build(context)
      @instrumentation_provider_builder.build(context)
      @provision_provider_builder.build(context)
      return context
    end

  end
end