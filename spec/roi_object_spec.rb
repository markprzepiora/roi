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
