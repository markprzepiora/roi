describe "Roi.any" do
  class FailingEmpty
    def empty?
      fail "unexpected error"
    end
  end

  include_examples "passing and failing values",
    schema: 'Roi.any',
    passing_values: ['a string', 123, {}, [], false, true],
    failing_values: [nil]

  describe ".must_be" do
    include_examples "passing and failing values",
      schema: 'Roi.any.must_be(:empty?)',
      passing_values: [ [], '', {}],
      failing_values: [ 1, true, false, [1], 'x', {one: 1}]

    include_examples "error message",
      schema: 'Roi.any.must_be(:empty?)',
      input_value: FailingEmpty.new,
      error_message: '#empty? must be true',
      error_path: [],
      error_validator_name: 'any.must_be'
  end

  describe ".must_not_be" do
    include_examples "passing and failing values",
      schema: 'Roi.any.must_not_be(:empty?)',
      passing_values: [ 1, true, false, [1], 'x', {one: 1}],
      failing_values: [ [], '', {}]

    include_examples "error message",
      schema: 'Roi.any.must_not_be(:empty?)',
      input_value: FailingEmpty.new,
      error_message: '#empty? must be false',
      error_path: [],
      error_validator_name: 'any.must_not_be'
  end
end
