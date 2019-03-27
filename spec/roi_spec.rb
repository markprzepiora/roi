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

    it "ignores keys missing from the validated object" do
      value = { first_name: "Mark" }
      schema = Roi.object.keys({
        first_name: Roi.string,
        last_name: Roi.string,
      })
      result = schema.validate(value)

      result.should be_ok
      result.value.should == { first_name: "Mark" }
    end
  end

  describe "errors" do
    it "returns an error when a validation fails" do
      value = { name: 123 }
      schema = Roi.object.keys({
        name: Roi.string
      })
      result = schema.validate(value)

      result.should_not be_ok
      result.errors.length.should == 1
    end

    it "creates an error with a path and other information" do
      value = { name: 123 }
      schema = Roi.object.keys({
        name: Roi.string
      })
      result = schema.validate(value)

      result.should_not be_ok
      error = result.errors.first
      error.path.should == [:name]
      error.validator_name.should == 'string'
      error.message.should == 'must be a string'
    end

    it "creates an error with a path and other information" do
      value = { first_name: 123 }
      schema = Roi.object.keys({
        first_name: Roi.string
      })
      result = schema.validate(value)

      result.should_not be_ok
      error = result.errors.first
      error.path.should == [:first_name]
      error.validator_name.should == 'string'
      error.message.should == 'must be a string'
    end

    it "creates an error with a nested path" do
      value = { user: { first_name: 123 } }
      schema = Roi.object.keys({
        user: Roi.object.keys({
          first_name: Roi.string,
        }),
      })
      result = schema.validate(value)

      result.should_not be_ok
      error = result.errors.first
      error.path.should == [:user, :first_name]
      error.validator_name.should == 'string'
      error.message.should == 'must be a string'
    end
  end
end
