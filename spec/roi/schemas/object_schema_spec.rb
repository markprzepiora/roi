describe "Roi.object" do
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

  include_examples "error message",
    schema: 'Roi.object',
    input_value: 123,
    error_message: 'must be a Hash',
    error_path: [],
    error_validator_name: 'object'

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
      error_validator_name: 'required'
  end

  describe ".require" do
    include_examples "passing and failing values",
      schema: 'Roi.object.require({ name: Roi.string })',
      passing_values: [ { name: "Mark", age: 32 } ],
      failing_values: [ { age: 32 } ]
  end

  describe "transforming a property" do
    include_examples "filters input value",
      schema: 'Roi.object.keys({ age: Roi.int.cast })',
      input_value: { age: "18" },
      output_value: { age: 18 }
  end
end
