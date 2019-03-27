describe "Roi.enum" do
  include_examples "passing and failing values",
    schema: 'Roi.enum("male", "female", nil)',
    passing_values: [ 'male', 'female', nil ],
    failing_values: [ '', 'MALE', false, true ]
end
