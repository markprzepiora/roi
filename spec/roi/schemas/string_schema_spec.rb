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

  describe ".length(Integer)" do
    include_examples "passing and failing values",
      schema: 'Roi.string.length(5)',
      passing_values: [ '12345', '☃☃☃☃☃' ],
      failing_values: [ '', '1', '1234', '123456' ]
  end

  describe ".length(Range)" do
    include_examples "passing and failing values",
      schema: 'Roi.string.length(1..5)',
      passing_values: [ '1', '12345', ],
      failing_values: [ '', '123456' ]

    include_examples "passing and failing values",
      schema: 'Roi.string.length(1...5)',
      passing_values: [ '1', '1234', ],
      failing_values: [ '', '12345' ]
  end

  describe ".min_length(Integer)" do
    include_examples "passing and failing values",
      schema: 'Roi.string.min_length(5)',
      passing_values: [ '12345', '123456' ],
      failing_values: [ '', '1', '1234' ]
  end

  describe ".max_length(Integer)" do
    include_examples "passing and failing values",
      schema: 'Roi.string.max_length(5)',
      passing_values: [ '', '1', '1234', '12345' ],
      failing_values: [ '123456' ]
  end
end
