require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/command_line/parser"

describe "Commandline::Parser" do
  let(:parser) { CommandLine::Parser.new() }

  it "should create parser" do
    parser.wont_be_nil
  end

  describe "execute" do
    let(:option_parser) { OptionParser.new() }
    let(:parser) { CommandLine::Parser.new(option_parser) }

    it "should raise error with unsupported flag" do
      command_line_arguments = ['--unsupported']
      assert_raises StandardError do
        parser.execute(command_line_arguments)
      end
    end

    it "should raise error with supported flag with missing argument" do
      command_line_arguments = ["--supported"]
      option_parser.on('-s', '--supported TEST', 'Test')
      assert_raises StandardError do
        parser.execute(command_line_arguments)
      end
    end
  end

end