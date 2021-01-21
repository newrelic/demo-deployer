require "./src/common/ansible/player"
require "./src/common/validation_error"
require "./src/common/install/params_reader"

module Teardown
  class Terminator

    def initialize(player_construct_lambda = lambda { return Common::Ansible::Player.new() })
      @player_construct_lambda = player_construct_lambda
    end

    def execute(template_contexts, isAsync = true)
      player = @player_construct_lambda.call()
      template_contexts.each do |template_context|
        execution_path = template_context.get_execution_path()
        directory_exist = File.directory?(execution_path)
        script_path = template_context.get_template_output_file_path()
        on_executed_handlers = []
        output_params = template_context.get_resource().get_params()
        unless output_params.nil?
          artifact_filename = "#{execution_path}/artifact.json"
          on_executed_handlers.push(lambda{ read_params_output(output_params, artifact_filename) })
        end
        Common::Logger::LoggerFactory.get_logger().debug("Terminator() execution_path:#{execution_path} execution_path_exist:#{directory_exist}")
        if directory_exist == true
          play = Common::Ansible::Play.new("#{template_context.get_resource_id()} :: teardown", script_path, nil, execution_path, nil, on_executed_handlers)
          player.stack(play)
        end
      end

      errors = player.execute(isAsync)

      errors.compact()
      unless errors.empty?
        raise Common::ValidationError.new("Running plays to terminate cloud assets failed:", errors)
      end

      return []
    end

    private
    def read_params_output(output_params, artifact_filename)
      if File.exists?(artifact_filename)
        reader = Common::Install::ParamsReader.new(output_params)
        reader.read_from_file(artifact_filename)
      end
    end

  end
end