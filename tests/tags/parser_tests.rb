require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/tags/parser"
require "./src/tags/parsed_output"

describe "Tags::Parser" do
  describe "execute" do
    let(:parser) { Tags::Parser.new() }

    it "should return an empty array when File is nil" do
       parsed_output = parser.execute(nil)
       assert_kind_of(Tags::ParsedOutput, parsed_output)
    end

    it "should return the contents of the 'tags' object" do
      config_file = '{"global_tags":{
        "tag1":"tag1value"
      }}'
      parsed_output = parser.execute(config_file)
      parsed_output.get_global_tags().must_equal({"tag1"=>"tag1value"})
    end

    it "should return an empty hash 'global_tags' object" do
      config_file = '{"global_tags":{}}'      
      parsed_output = parser.execute(config_file)
      parsed_output.get_global_tags().must_equal({})
    end

    it "should not error if 'global_tags' object does not exist" do
      config_file = '{}'      
      parsed_output = parser.execute(config_file)
      parsed_output.get_global_tags().must_equal({})
    end

    it "should return the contents of a single resource 'tags' object" do
      config_file = '{"resources":[
        {
          "id":"key1",
          "tags": {"tag1":"tag1value"}
        }
        ]}'
      parsed_output = parser.execute(config_file)
      tags = parsed_output.get_resources_tags()["key1"]
      tags.must_equal({"tag1"=>"tag1value"})
    end
    
    it "should return the contents of multiple resources 'tags' object" do
      config_file = '{"resources":[
        {
          "id":"key1",
          "tags": {"tag1":"tag1value"}
        },{
          "id":"key2",
          "tags": {"tag2":"tag2value"}
        }
        ]}'
      parsed_output = parser.execute(config_file)
      parsed_output.get_resources_tags()["key1"].must_equal({"tag1"=>"tag1value"})
      parsed_output.get_resources_tags()["key2"].must_equal({"tag2"=>"tag2value"})
    end
    
    it "should return a single tags for multiple same resource" do
      config_file = '{"resources":[
        {
          "id":"key",
          "tags": {"tag":"tag1value"}
        },{
          "id":"key",
          "tags": {"tag":"tag2value"}
        }
        ]}'
      parsed_output = parser.execute(config_file)
      parsed_output.get_resources_tags()["key"].must_equal({"tag"=>"tag2value"})
    end
    
    it "should return an empty tags when a resource does not have any" do
      config_file = '{"resources":[
        {
          "id":"key"
        }
        ]}'
      parsed_output = parser.execute(config_file)
      parsed_output.get_resources_tags()["key"].must_equal({})
    end
    
    it "should return an empty hashtable when no resource id" do
      config_file = '{"resources":[
        {
          "missing":"key"
        }
        ]}'
      parsed_output = parser.execute(config_file)
      parsed_output.get_resources_tags().must_be_empty()
    end







    it "should return the contents of a single service 'tags' object" do
      config_file = '{"services":[
        {
          "id":"key1",
          "tags": {"tag1":"tag1value"}
        }
        ]}'
      parsed_output = parser.execute(config_file)
      tags = parsed_output.get_services_tags()["key1"]
      tags.must_equal({"tag1"=>"tag1value"})
    end
    
    it "should return the contents of multiple services 'tags' object" do
      config_file = '{"services":[
        {
          "id":"key1",
          "tags": {"tag1":"tag1value"}
        },{
          "id":"key2",
          "tags": {"tag2":"tag2value"}
        }
        ]}'
      parsed_output = parser.execute(config_file)
      parsed_output.get_services_tags()["key1"].must_equal({"tag1"=>"tag1value"})
      parsed_output.get_services_tags()["key2"].must_equal({"tag2"=>"tag2value"})
    end
    
    it "should return a single tags for multiple same service" do
      config_file = '{"services":[
        {
          "id":"key",
          "tags": {"tag":"tag1value"}
        },{
          "id":"key",
          "tags": {"tag":"tag2value"}
        }
        ]}'
      parsed_output = parser.execute(config_file)
      parsed_output.get_services_tags()["key"].must_equal({"tag"=>"tag2value"})
    end
    
    it "should return an empty tags when a service does not have any" do
      config_file = '{"services":[
        {
          "id":"key"
        }
        ]}'
      parsed_output = parser.execute(config_file)
      parsed_output.get_services_tags()["key"].must_equal({})
    end
    
    it "should return an empty hashtable when no service id" do
      config_file = '{"services":[
        {
          "missing":"key"
        }
        ]}'
      parsed_output = parser.execute(config_file)
      parsed_output.get_services_tags().must_be_empty()
    end






  end
end