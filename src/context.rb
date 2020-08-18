class Context

  def initialize()
    @context = {}
  end

  def set_command_line_provider(provider)
    @context[:command_line_provider] = provider
  end

  def get_command_line_provider()
    @context[:command_line_provider]
  end

  def set_app_config_provider(provider)
    @context[:app_config_provider] = provider
  end

  def get_app_config_provider()
    @context[:app_config_provider]
  end

  def set_infrastructure_provider(provider)
    @context[:infrastructure_provider] = provider
  end

  def get_infrastructure_provider()
    @context[:infrastructure_provider]
  end
  
  def set_instrumentation_provider(provider)
    @context[:instrumentation_provider] = provider
  end

  def get_instrumentation_provider()
    @context[:instrumentation_provider]
  end

  def set_user_config_provider(provider)
    @context[:user_config_provider] = provider
  end

  def get_user_config_provider()
    @context[:user_config_provider]
  end

  def set_tags_provider(provider)
    @context[:tags_provider] = provider
  end

  def get_tags_provider()
    @context[:tags_provider]
  end

  def set_services_provider(provider)
    @context[:services_provider] = provider
  end

  def get_services_provider()
    @context[:services_provider]
  end

  def set_deployment_provider(provider)
    @context[:deployment_provider] = provider
  end

  def get_deployment_provider()
    @context[:deployment_provider]
  end

  def set_provision_provider(provider)
    @context[:provision_provider] = provider
  end

  def get_provision_provider()
    @context[:provision_provider]
  end
  
  def set_install_provider(provider)
    @context[:install_provider] = provider
  end

  def get_install_provider()
    @context[:install_provider]
  end

end


