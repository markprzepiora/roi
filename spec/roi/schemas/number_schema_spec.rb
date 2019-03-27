describe "Roi.number" do
  include_examples "passing and failing values",
    schema: 'Roi.number',
    passing_values: [1, 1.0, 0, -1, 1.5, Float::INFINITY, Float::NAN],
    failing_values: [nil, 'a string', '1.23']

  include_examples "filters input value",
    schema: 'Roi.number',
    input_value: 10.4,
    output_value: 10.4

  include_examples "error message",
    schema: 'Roi.number',
    input_value: '1.25',
    error_message: 'must be a number'

  describe ".min" do
    include_examples "passing and failing values",
      schema: 'Roi.number.min(9.99)',
      passing_values: [ 9.99, 10, 11 ],
      failing_values: [ 9 ]
  end

  describe ".max" do
    include_examples "passing and failing values",
      schema: 'Roi.number.max(10.0)',
      passing_values: [ 9, 10, 10.0 ],
      failing_values: [ 11 ]
  end
end
