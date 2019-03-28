describe Roi::Schemas::BaseSchema do
  it "has a name" do
    described_class.new.name.should == 'base'
  end

  describe ".allow" do
    include_examples "passing and failing values",
      schema: 'Roi.int.min(10).allow(5, 6)',
      passing_values: [5, 6, 10, 11],
      failing_values: [9]

    include_examples "passing and failing values",
      schema: 'Roi.int.min(10).allow(nil)',
      passing_values: [nil, 10, 11],
      failing_values: [9]

    include_examples "passing and failing values",
      schema: 'Roi.int.min(10).or_nil',
      passing_values: [nil, 10, 11],
      failing_values: [9]
  end

  describe ".invalid" do
    include_examples "passing and failing values",
      schema: 'Roi.int.min(10).invalid(12)',
      passing_values: [10, 11, 13],
      failing_values: [12]
  end
end
