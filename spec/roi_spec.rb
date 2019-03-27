describe Roi do
  shared_examples "passing and failing values" do |schema:, passing_values: [], failing_values: []|
    schema_string = schema

    describe "schema #{schema_string}" do
      passing_values.each do |input_value|
        it "validates #{input_value.inspect}" do
          schema = eval(schema_string)
          result = schema.validate(input_value)
          result.should be_ok
        end
      end

      failing_values.each do |input_value|
        it "rejects #{input_value.inspect}" do
          schema = eval(schema_string)
          result = schema.validate(input_value)
          result.should_not be_ok
        end
      end
    end
  end

  it "has a version number" do
    Roi::VERSION.should_not be_nil
  end

  describe ".string" do
    include_examples "passing and failing values",
      schema: 'Roi.string',
      passing_values: ['a string'],
      failing_values: [nil]
  end

  describe ".int" do
    include_examples "passing and failing values",
      schema: 'Roi.int',
      passing_values: [123, 123.0],
      failing_values: [nil, 'a string', 123.50]

    it "converts floats with 0-decimal-parts to integers" do
      result = Roi.int.validate(123.0)

      result.should be_ok
      result.value.should equal(123)
      result.value.should be_a(Integer)
    end

    it "rejects non-integer floats" do
      result = Roi.int.validate(1.25)

      error = result.errors.first

      error.validator_name.should == 'int'
      error.message.should == 'must be an integer'
      error.path.should == []
    end

    describe ".min" do
      include_examples "passing and failing values",
        schema: 'Roi.int.min(10)',
        passing_values: [ 10, 11 ],
        failing_values: [ 9 ]
    end

    describe ".max" do
      include_examples "passing and failing values",
        schema: 'Roi.int.max(10)',
        passing_values: [ 9, 10 ],
        failing_values: [ 11 ]
    end
  end

  describe ".object" do
    include_examples "passing and failing values",
      schema: 'Roi.object',
      passing_values: [ {} ],
      failing_values: [ "a string", nil ]

    include_examples "passing and failing values",
      schema: 'Roi.object.keys({ name: Roi.string })',
      passing_values: [ { name: "Mark" }, {} ],
      failing_values: [ { name: 123 } ]

    it "removes unspecified keys" do
      value = { name: "Mark", age: 32 }
      schema = Roi.object.keys({ name: Roi.string })

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
