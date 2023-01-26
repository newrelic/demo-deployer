require "open-uri"
require "./src/common/tasks/process_task"
require "./src/common/logger/logger_factory"

module CommandLine
  class Provider

    def initialize(context, options)
      @context = context
      @options = options
      @config_loader_lambda = lambda { |filepath| return get_file_content(filepath) }
    end

    def get_user_config_content()
      filepath = @options[:user_config]
      @user_file_content ||= @config_loader_lambda.call(filepath)
      return @user_file_content
    end

    def get_deployment_config_content()
      filepath = @options[:deploy_config]
      @deploy_file_content ||= @config_loader_lambda.call(filepath)
      return @deploy_file_content
    end

    def is_teardown?()
      return @options[:is_teardown] == true
    end

    def get_user_config_filepath()
      return @options[:user_config]
    end

    def get_user_config_name()
      filepath = get_user_config_filepath()
      config_name = strip_to_name(filepath)
      return config_name
    end

    def get_deploy_config_name()
      input = @options[:deploy_config]
      if is_url?(input)
        config_name = get_local_name_for_remote(input)
      else
        config_name = input
      end
      config_name = strip_to_name(config_name)
      return config_name
    end

    def get_deploy_config_filepath()
      input = @options[:deploy_config]
      if is_url?(input)
        return get_local_path_for_remote(input)
      end
      return input
    end

    def get_deployment_name()
      username = get_user_config_name()
      deployname = get_deploy_config_name()
      return "#{username}-#{deployname}"
    end

    def get_logging_level()
      return @options[:logging_level].downcase()
    end

    def get_deployment_config(object_class = Hash)
      deploy_config_content = get_deployment_config_content || "{}"
      return JSON.parse(deploy_config_content, object_class: object_class)
    end

    def get_output_file_path()
      return @options[:output_file_path]
    end

    def is_output_ini?()
      return @options[:output_ini]
    end
  
    private
    def download_file(url, filepath)
      Common::Logger::LoggerFactory.get_logger().debug("Downloading from #{url} to #{filepath}")
      download = open(url)
      IO.copy_stream(download, filepath)
    end

    def get_file_content(input)
      unless input.nil?
        filepath = input
        if is_url?(input)
          filepath = get_local_path_for_remote(input)
          download_file(input, filepath)
        end
        return File.read(filepath)
      end
      return nil
    end

    def get_local_path_for_remote(input)
      filename = get_local_name_for_remote(input)
      deployment_path = get_deployment_path()
      directory_service = Common::Io::DirectoryService.new(deployment_path)
      directory = directory_service.create_sub_directory("downloads")
      filepath = "#{directory}/#{filename}"
      return filepath
    end

    def get_local_name_for_remote(input)
      filename = input.split('/').last
      return filename
    end

    def strip_to_name(filepath)
      unless filepath.nil?
        filename = File.basename(filepath)
        split = filename.split('.').first
        return split
      end
      return nil
    end

    def is_url?(input)
      if input!=nil && input.downcase().start_with?("http")
        return true
      end
      return false
    end


    def get_execution_path()
      return @execution_path ||= @context.get_app_config_provider().get_execution_path()
    end

    def get_deployment_path()
      return @deployment_path ||= "#{get_execution_path()}/#{get_deployment_name()}"
    end

  end
end
