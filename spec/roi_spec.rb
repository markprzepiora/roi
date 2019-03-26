describe Roi do
  it "has a version number" do
    Roi::VERSION.should_not be_nil
  end

  it "successfully validates a trivial schema and returns the input" do
    hash = {}
    schema = Roi.object
    result = schema.validate(hash)

    result.should be_ok
    result.value.should == hash
  end

  it "rejects a non-Hash when the schema is of type object" do
    value = "a string"
    schema = Roi.object
    result = schema.validate(value)

    result.should_not be_ok
  end
end
