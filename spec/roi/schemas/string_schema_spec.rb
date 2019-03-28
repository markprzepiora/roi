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
      passing_values: ['a string', ' /', "my value".encode("UTF-16LE")],
      failing_values: ["", "   ", "  \n\t  \r ", "　", "\u00a0", " ".encode("UTF-16LE") ]
  end

  describe ".regex" do
    include_examples "passing and failing values",
      schema: 'Roi.string.regex(/\A[a-z]*\z/i)',
      passing_values: ['foo', 'BAR', 'bAz', ''],
      failing_values: [ '0', '*' ]
  end

  describe ".digits" do
    include_examples "passing and failing values",
      schema: 'Roi.string.digits',
      passing_values: [ '0', '1', '123' ],
      failing_values: [ '-0', '', '1.5' ]
  end
end
