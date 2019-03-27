describe "Roi.boolean" do
  include_examples "passing and failing values",
    schema: 'Roi.boolean',
    passing_values: [ true, false ],
    failing_values: [ nil, 'true', 'false', 0, 1, '0', '1', 'on', 'off' ]
end
