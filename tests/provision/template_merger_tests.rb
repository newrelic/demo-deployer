require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/template_merger"

describe "Provision::TemplateMerger" do
  let(:binding) {}
  let(:file_context) { "" }
  let(:template_context) { m = mock(); m.stubs(:get_template_input_file_path);m.stubs(:get_template_output_file_path); m.stubs(:get_template_binding).returns(binding); m  }
  let(:template_merger) { Common::TemplateMerger.new() }
  let(:file_object_mock) {m = mock(); m.stubs(:close).returns({}); m }


  before do
    File.stubs(:open).returns(file_object_mock)
    File.stubs(:read).returns("")
    ERB.stubs(:result).with(:updated_at).returns("")
  end

  describe "merge and save template" do
    it "should not fail" do
      expect(template_merger.merge_template_save_file(template_context)).wont_be_nil
    end
  end
end
