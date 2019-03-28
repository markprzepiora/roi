describe "Roi.array" do
  include_examples "passing and failing values",
    schema: 'Roi.array',
    passing_values: [ [], [1], [nil] ],
    failing_values: [ {}, nil, 'a string', 123 ]

  include_examples "error message",
    schema: 'Roi.array',
    input_value: 123,
    error_message: 'must be an Array',
    error_path: []

  describe ".items" do
    include_examples "passing and failing values",
      schema: 'Roi.array.items(Roi.int)',
      passing_values: [ [], [1], [1,2,3] ],
      failing_values: [ nil, 1, {}, ['1'] ]

    include_examples "error message",
      schema: 'Roi.array.items(Roi.int)',
      input_value: [ 1, '2', 3 ],
      error_message: 'must be an Integer',
      error_path: [1]
  end

  describe ".nonempty" do
    include_examples "passing and failing values",
      schema: 'Roi.array.nonempty',
      passing_values: [ [1], [1,2,3] ],
      failing_values: [ [], nil ]
  end
end
