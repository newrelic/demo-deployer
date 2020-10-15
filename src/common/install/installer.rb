require "./src/common/ansible/player"
require "./src/common/ansible/play"
require "./src/common/install/composer"
require "./src/common/install/params_reader"
require "./src/common/install_error"
require "./src/common/logger/logger_factory"

module Common
  module Install
    class Installer

      def initialize(directory_service,
                     player_construct_lambda = lambda { return Common::Ansible::Player.new() },
                     composer = nil)

        @directory_service = directory_service
        @player_construct_lambda = player_construct_lambda
        @composer = composer
        @steps = []
        @isWarningOnError = false
      end

      def execute(install_definitions)
        @steps.each do | step|
          if step[:serial_step]
            install_serially_per_host(step[:action_name], install_definitions)
          else
            install(step[:action_name], install_definitions)
          end
        end
      end

      def queue_step(action_name, serial_step = false)
        step = {action_name:action_name, serial_step: serial_step}
        @steps.push(step)
        return self
      end

      def warn_on_error(value = true)
        @isWarningOnError = value
      end

      private
      def install(action_name, install_definitions)
        install_contexts = get_composer().execute(action_name, install_definitions)
        execute_install(action_name, install_contexts)
      end

      def install_serially_per_host(action_name, install_definitions)
        composed_contexts = get_composer().execute(action_name, install_definitions)
        grouped_contexts = partition_by_host(composed_contexts)
        begin
          has_installed_any = execute_group(action_name, grouped_contexts)
        end while has_installed_any == true
      end

      def execute_group(action_name, grouped_contexts)
        install_contexts = []
        grouped_contexts.each do |grouped_context|
          if grouped_context.length>0
            context = grouped_context.pop()
            install_contexts.push(context)
          end
        end
        if install_contexts.length > 0
          execute_install(action_name, install_contexts)
          return true
        end
        return false
      end

      def execute_install(action_name, install_contexts, isAsync = true)
        player = @player_construct_lambda.call()
        install_contexts.each do |install_context|
          action_execution_path = install_context.get_execution_path()
          host_file_path = install_context.get_host_file_path()
          script_path = install_context.get_install_script_path()
          directory_exist = File.directory?(action_execution_path)
          host_exist = install_context.host_exist?()
          output_params = install_context.get_output_params()
          on_executed_handlers = []
          unless output_params.nil?
            artifact_filename = "#{action_execution_path}/artifact.json"
            on_executed_handlers.push(lambda{ read_params_output(output_params, artifact_filename) })
          end
          Common::Logger::LoggerFactory.get_logger().debug("Installer() execution_path:#{action_execution_path} execution_path_exist:#{directory_exist} host_file_path:#{host_file_path} script_path:#{script_path} host_exist:#{host_exist}")
          if directory_exist == true
            play = Common::Ansible::Play.new(script_path, host_file_path, action_execution_path, host_exist, on_executed_handlers)
            player.stack(play)
          end
        end

        errors = player.execute(isAsync)

        if errors.length > 0
          if @isWarningOnError
            Common::Logger::LoggerFactory.get_logger().debug("Installation failed at the '#{action_name}' step, details:#{errors}")
          else
            raise Common::InstallError.new("Installation failed at the '#{action_name}' step", errors)
          end
        end
      end

      def read_params_output(output_params, artifact_filename)
        if File.exists?(artifact_filename) 
          reader = Common::Install::ParamsReader.new(output_params)
          reader.read_from_file(artifact_filename) 
        end
      end

      def partition_by_host(contexts)
        return contexts.group_by { |context| context.get_host_id() }.values
      end

      def get_composer()
        return @composer ||= Common::Install::Composer.new(@directory_service)
      end

    end
  end
end