require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/comparable_array_validator"

describe "Common" do
  describe "Validators" do
    describe "ComparableArrayValidator" do
      let(:resources) { [] }
      let(:entities) { [] }
      let(:validator) { Common::Validators::ComparableArrayValidator.new()}
      
      it "should create validator" do
        validator.wont_be_nil
      end

      it "should find no missing element when nothing to compare" do
        validator.execute(resources, "id", entities).must_be_nil()
      end

      it "should find no missing element when same" do
        given_resource("hostname1", "test provider")

        validator.execute(resources, "id", resources).must_be_nil()
      end
      
      it "should find no missing element when comparable arrays" do
        given_resource("hostname1", "test provider")

        given_entity("hostname1", "1.2.3.4")

        validator.execute(resources, "id", entities).must_be_nil()
      end
      
      it "should find no missing element when comparing different keys" do
        given_resource("hostname1", "localhost")

        given_entity("hostname1", "localhost")

        validator.execute(resources, "provider", entities, "ip").must_be_nil()
      end
      
      it "should find no missing element when source has less items" do
        given_resource("hostname1")

        given_entity("hostname2")
        given_entity("hostname1")
        given_entity("hostname4")

        validator.execute(resources, "id", entities).must_be_nil()
      end

      it "should find no missing element when source has none" do
        given_entity("hostname1")

        validator.execute(resources, "id", entities).must_be_nil()
      end

      it "should find not missing any elements when source has many" do
        given_resource("hostname3")
        given_resource("hostname2")
        given_resource("hostname1")

        given_entity("hostname2")
        given_entity("hostname3")
        given_entity("hostname1")

        validator.execute(resources, "id", entities).must_be_nil()
      end

      it "should find missing element" do
        given_resource("hostname1")

        validator.execute(resources, "id", entities).must_include("hostname1")
      end

      it "should find multiple missing elements" do
        given_resource("hostname1")
        given_resource("hostname2")

        error = validator.execute(resources, "id", entities)
        
        error.must_include("hostname1")
        error.must_include("hostname2")
      end

      it "should find some missing elements" do
        given_resource("hostname1")
        given_resource("hostname2")
        given_resource("hostname4")
        given_resource("hostname3")
        
        given_entity("hostname1")
        given_entity("hostname3")

        error = validator.execute(resources, "id", entities)
        error.must_include("hostname2")
        error.must_include("hostname4")
      end

      it "should find missing element when using wrong key" do
        given_resource("hostname1", "test provider")

        given_entity("hostname1", "1.2.3.4")

        validator.execute(resources, "provider", entities, "ip").must_include("hostname1")
      end

      it "should not find anything when key does not exist on source" do
        given_resource("hostname1")

        given_entity("hostname1")

        validator.execute(resources, "invalid", entities, "id").must_be_nil()
      end

      it "should find when key does not exist on items" do
        given_resource("hostname1")

        given_entity("some other host")

        validator.execute(resources, "id", entities, "invalid").must_include("hostname1")
      end
      
      it "should find when specified key does not exist on items but source key does exist and would have match" do
        given_resource("hostname1")

        given_entity("hostname1")
        
        validator.execute(resources, "id", entities, "invalid").must_include("hostname1")
      end

      it "should find multiple missing" do
        given_resource("hostname1")
        given_resource("hostname2")
        given_resource("hostname3")

        given_entity("hostname2")
        given_entity("hostname4")
        given_entity("hostname6")

        error = validator.execute(resources, "id", entities)
        error.must_include("hostname1")
        error.must_include("hostname3")
      end

      def given_resource(id, provider = nil)
        resources.push({"id"=> id, "provider" => provider})
      end
      
      def given_entity(id, ip = nil)
        entities.push({"id"=> id, "ip" => ip})
      end

    end
  end
end