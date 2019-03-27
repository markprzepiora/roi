describe "Roi.any" do
  include_examples "passing and failing values",
    schema: 'Roi.any',
    passing_values: ['a string', 123, {}, [], false, true],
    failing_values: [nil]

  describe ".must_be" do
    include_examples "passing and failing values",
      schema: 'Roi.any.must_be(:empty?)',
      passing_values: [ [], '', {}],
      failing_values: [ 1, true, false, [1], 'x', {one: 1}]
  end

  describe ".must_not_be" do
    include_examples "passing and failing values",
      schema: 'Roi.any.must_not_be(:empty?)',
      passing_values: [ 1, true, false, [1], 'x', {one: 1}],
      failing_values: [ [], '', {}]
  end
end
