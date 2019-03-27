describe "Roi.string" do
  include_examples "passing and failing values",
    schema: 'Roi.string',
    passing_values: ['a string'],
    failing_values: [nil]

  describe ".nonempty" do
    include_examples "passing and failing values",
      schema: 'Roi.string.nonempty',
      passing_values: ['a string', ' '],
      failing_values: ['']
  end

  describe ".present" do
    include_examples "passing and failing values",
      schema: 'Roi.string.present',
      passing_values: ['a string', ' /'],
      failing_values: ['', ' ', " \n "]
  end

  describe ".regex" do
    include_examples "passing and failing values",
      schema: 'Roi.string.regex(/\A[a-z]*\z/i)',
      passing_values: ['foo', 'BAR', 'bAz', ''],
      failing_values: [ '0', '*' ]
  end
end
