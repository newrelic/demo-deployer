require 'minitest/spec'
require 'minitest/autorun'
require 'mocha/minitest'

require './src/summary/footnote_validator'

describe 'Summary' do
  describe 'FootnoteValidator' do
    deploy_config = {}
    deploy_config_func = lambda { return deploy_config }
    let(:validator) { Summary::FootnoteValidator.new }

    it 'should create validator' do
      validator.wont_be_nil
    end

    it 'should return nil when output field doesnt exist' do
      deploy_config = {}
      validator.execute(deploy_config_func).must_be_nil
    end

    it 'should return nil when footnote field doesnt exist' do
      deploy_config = { 'output' => {} }
      validator.execute(deploy_config_func).must_be_nil
    end

    it 'should return nil when footnote is a string' do
      deploy_config = { 'output' => { 'footnote' => 'example footnote' } }
      validator.execute(deploy_config_func).must_be_nil
    end

    it 'should return nil when footnote is an array of strings' do
      deploy_config = { 'output' => { 'footnote' => ['example', 'footnote'] } }
      validator.execute(deploy_config_func).must_be_nil
    end

    it 'should return error message' do
      deploy_config = { 'output' => { 'footnote' => 3 } }
      errorMessage = validator.execute(deploy_config_func)
      errorMessage.index("'footnote' field must be of type 'String' or 'Array<String>'").must_equal(0)
    end
  end
end
