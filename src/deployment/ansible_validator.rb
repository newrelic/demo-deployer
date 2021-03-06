require './src/common/tasks/process_task'

module Deployment
  class AnsibleValidator
    def initialize(command = "ansible --version",
                   ansible_min_version = 2.8)
      @command = command
      @ansible_min_version = Gem::Version.new(ansible_min_version)
    end

    def execute(execution_path)
      errors = []

      task = Common::Tasks::ProcessTask.new(@command, execution_path)
      processs_output = task.wait_to_completion()

      if processs_output.succeeded?
        command_output = processs_output.get_stdout()
        possible_ansible_version = command_output.match(/(\d+\.\d+)/)

        if possible_ansible_version.nil?
          errors << "Command '#{@command}'' didn't find an Ansible version with output: #{command_output.to_s}"
        else
          ansible_version = Gem::Version.new(possible_ansible_version[0])
          if ansible_version < @ansible_min_version
              errors << ("Your current version of Ansible #{ansible_version} is below the currently supported minimum version of #{@ansible_min_version}")
          end
        end
      else
        errors << "Failed to execute command: '#{@command}'"
      end

      if errors.length > 0
        return errors
      end

      return nil
    end
  end

end
