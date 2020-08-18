require 'erb'
require 'fileutils'

module Common
  class TemplateMerger

    def merge_template_save_file(template_context)
      result = merge_template(template_context.get_template_input_file_path(), template_context.get_template_binding())
      save_playbook_file(template_context.get_template_output_file_path(), result)
    end

    private
    def merge_template(template_path, template_binding)
      erb_str = File.read(template_path)
      renderer = ERB.new(erb_str)
      return renderer.result(template_binding)
    end

    def save_playbook_file(output_file_name, result)
      File.open("#{output_file_name}", 'w') do |f|
        f.write(result)
      end
    end

  end
end
