describe "Roi.int" do
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

  describe ".cast" do
    include_examples "passing and failing values",
      schema: 'Roi.int.cast',
      passing_values: [ 1, "1", "123", "-0" ],
      failing_values: [ "", nil, "1.1" ]

    include_examples "filters input value",
      schema: 'Roi.int.cast',
      input_value: 1.1,
      output_value: 1

    include_examples "filters input value",
      schema: 'Roi.int.cast',
      input_value: "1",
      output_value: 1

    include_examples "filters input value",
      schema: 'Roi.int.cast',
      input_value: "-0",
      output_value: 0
  end
end
