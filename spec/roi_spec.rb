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

  shared_examples "filters input value" do |schema:, input_value:, output_value:|
    schema_string = schema

    describe "schema #{schema_string} on input #{input_value.inspect}" do
      let(:real_schema) { eval(schema_string) }
      let(:result) { real_schema.validate(input_value) }

      it "passes" do
        result.should be_ok
      end

      it "returns the value #{output_value.inspect}" do
        result.value.should == output_value
      end

      it "returns a #{output_value.class}" do
        result.value.class.should == output_value.class
      end
    end
  end

  shared_examples "error message" do |schema:, input_value:, error_message: nil, error_path: nil, error_validator_name: nil|
    schema_string = schema

    describe "schema #{schema_string} on input #{input_value.inspect}" do
      let(:real_schema) { eval(schema_string) }
      let(:result) { real_schema.validate(input_value) }
      let(:errors) { result.errors }

      it "rejects" do
        result.should_not be_ok
      end

      it "has an error" do
        errors.should_not be_empty
      end

      if error_message
        it "has error #{error_message.inspect}" do
          errors.first.message.should match(error_message)
        end
      end

      if error_path
        it "has error path #{error_path.inspect}" do
          errors.first.path.should == error_path
        end
      end

      if error_validator_name
        it "has error validator name #{error_validator_name.inspect}" do
          errors.first.validator_name.should == error_validator_name
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

    include_examples "filters input value",
      schema: 'Roi.int',
      input_value: 10.0,
      output_value: 10

    include_examples "error message",
      schema: 'Roi.int',
      input_value: 1.25,
      error_message: 'must be an integer'

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

    include_examples "filters input value",
      schema: 'Roi.object.keys({ name: Roi.string })',
      input_value: { name: "Mark", age: 32 },
      output_value: { name: "Mark" }

    # ignores keys missing from the validated object
    include_examples "filters input value",
      schema: 'Roi.object.keys({ first_name: Roi.string, last_name: Roi.string })',
      input_value: { first_name: "Mark" },
      output_value: { first_name: "Mark" }

    describe ".required" do
      include_examples "passing and failing values",
        schema: 'Roi.object.keys({ first_name: Roi.string.required, last_name: Roi.string.required })',
        passing_values: [
          { first_name: "Mark", last_name: "Przepiora" }
        ],
        failing_values: [
          {},
          { first_name: "Mark" },
        ]

      include_examples "error message",
        schema: 'Roi.object.keys({ first_name: Roi.string.required, last_name: Roi.string.required })',
        input_value: { first_name: "Mark" },
        error_message: 'object must have a value for key :last_name',
        error_path: [:last_name],
        error_validator_name: 'string.required'
    end
  end

  describe ".array" do
    include_examples "passing and failing values",
      schema: 'Roi.array',
      passing_values: [ [], [1], [nil] ],
      failing_values: [ {}, nil, 'a string', 123 ]

    include_examples "error message",
      schema: 'Roi.array',
      input_value: 123,
      error_message: 'must be an array',
      error_path: []

    describe ".items" do
      include_examples "passing and failing values",
        schema: 'Roi.array.items(Roi.int)',
        passing_values: [ [], [1], [1,2,3] ],
        failing_values: [ nil, 1, {}, ['1'] ]

      include_examples "error message",
        schema: 'Roi.array.items(Roi.int)',
        input_value: [ 1, '2', 3 ],
        error_message: 'must be an integer',
        error_path: [1]
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

  context "given a complete example (user endpoint)" do
    let(:user_schema) do
      Roi.object.keys({
        id: Roi.int.required.min(1),
        first_name: Roi.string.required,
        accounts: Roi.array.items(Roi.object.keys({
          id: Roi.int.required,
          name: Roi.string.required,
        }))
      })
    end
    let(:schema) { Roi.object.keys(user: user_schema) }

    it "validates a complete, passing example" do
      payload = {
        user: {
          id: 123,
          first_name: "Mark",
          accounts: [
            { id: 1, name: "My account" },
            { id: 2, name: "Another account" },
          ],
        },
      }
      result = schema.validate(payload)

      result.should be_ok
      result.value.should == payload
    end

    it "gives a correct error given an invalid account" do
      payload = {
        user: {
          id: 123,
          first_name: "Mark",
          accounts: [
            { id: 1, name: "My account" },
            { id: nil, name: "Another account" },
          ],
        },
      }
      result = schema.validate(payload)

      result.should_not be_ok
      result.errors.count.should == 1

      error = result.errors.first
      error.path.should == [:user, :accounts, 1, :id]
    end
  end
end
