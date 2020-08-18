require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/services/provider"

describe "Service::Provider" do
  let(:destination1_id) { 'host1' }
  let(:service1_id) { 'service1' }
  let(:service1)  { {'id' => service1_id, 'destinations' => [destination1_id], 'source_path' => '/path_to_source'} }
  let(:services)  { [] }
  let(:source_paths_file) { {"service1" => '/path_to_source'} }
  let(:tags_provider) { m = mock(); m.stubs(:get_service_tags).returns({}) ; m }
  let(:provider) { Services::Provider.new(services, source_paths_file, tags_provider) }

  it "should create provider" do
    provider.wont_be_nil
  end

  describe "services and destinations" do
    it "should return list of service definitions" do
      services.push(service1)
      provider.get_services().first.must_be_instance_of(Services::Definitions::Service)
    end
  end

  describe "aggregate value" do
    let(:destination2_id) { 'host2' }
    let(:service2_id) { 'service2' }
    let(:service2)  { {'id' => service2_id, 'destinations' => [destination2_id]} }

    it "should get no services with wrong destination" do
      services.push(service1)
      service_ids = provider.aggregate_value('no_destination') { |service| service.get_id() }
      service_ids.must_equal([])
    end

    it "should get service id" do
      services.push(service1)
      service_ids = provider.aggregate_value(destination1_id) { |service| service.get_id() }
      service_ids.must_include(service1_id)
    end

    it "should not get service id" do
      services.push(service1)
      services.push(service2)
      service_ids = provider.aggregate_value(destination1_id) { |service| service.get_id() }
      service_ids.wont_include(service2_id)
    end
  end

  describe "files" do
    let(:file1)  { {'destination_filepath' => 'mypath/myfile', 'content' => 'whatever content'} }
    let(:service_file)  { {'id' => 'myService', 'files' => [file1]} }
    it "should add single file" do
      services.push(service_file)
      instance = provider.get_services().first()
      file = instance.get_files().first()
      file.get_destination_filepath().must_equal('mypath/myfile')
      file.get_content().must_equal('whatever content')
    end
  end

end