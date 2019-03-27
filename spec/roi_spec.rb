describe Roi do
  it "has a version number" do
    Roi::VERSION.should_not be_nil
  end

  describe ".string" do
    it "validates a simple string schema (pass)" do
      value = "a string"
      schema = Roi.string
      result = schema.validate(value)

      result.should be_ok
      result.value.should == value
    end

    it "validates a simple string schema (fail)" do
      value = nil
      schema = Roi.string
      result = schema.validate(value)

      result.should_not be_ok
    end
  end

  describe ".object" do
    it "successfully validates a trivial object schema and returns the input" do
      hash = {}
      schema = Roi.object
      result = schema.validate(hash)

      result.should be_ok
      result.value.should == hash
    end

    it "rejects a non-Hash when the schema is of type object" do
      value = "a string"
      schema = Roi.object
      result = schema.validate(value)

      result.should_not be_ok
    end

    it "validates an object schema with a key (pass)" do
      value = { name: "Mark" }
      schema = Roi.object.keys({
        name: Roi.string
      })
      result = schema.validate(value)

      result.should be_ok
      result.value.should == value
    end

    it "validates an object schema with a key (fail)" do
      value = { name: 123 }
      schema = Roi.object.keys({
        name: Roi.string
      })
      result = schema.validate(value)

      result.should_not be_ok
    end

    it "removes unspecified keys" do
      value = { name: "Mark", age: 32 }
      schema = Roi.object.keys({
        name: Roi.string
      })
      result = schema.validate(value)

      result.should be_ok
      result.value.should == { name: "Mark" }
    end
  end
end
