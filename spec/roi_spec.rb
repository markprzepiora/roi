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

  describe ".int" do
    it "validates a simple integer schema (pass)" do
      value = 123
      schema = Roi.int
      result = schema.validate(value)

      result.should be_ok
      result.value.should == value
    end

    it "validates a float as long as it has a 0 decimal part" do
      value = 123.0
      schema = Roi.int
      result = schema.validate(value)

      result.should be_ok
      result.value.should == 123
      result.value.should be_a(Integer)
    end

    it "rejects non-integer floats" do
      value = 1.25
      schema = Roi.int
      result = schema.validate(value)

      result.should_not be_ok
      result.errors.count.should == 1

      error = result.errors.first

      error.validator_name.should == 'int'
      error.message.should == 'must be an integer'
      error.path.should == []
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

    it "requires keys marked as required" do
      value = { first_name: "Mark" }
      schema = Roi.object.keys({
        first_name: Roi.string.required,
        last_name: Roi.string.required,
      })
      result = schema.validate(value)

      result.should_not be_ok
      result.errors.count.should == 1

      error = result.errors.first
      error.path.should == [:last_name]
      error.message.should == "object must have a value for key :last_name"
      error.validator_name.should == 'string.required'
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
