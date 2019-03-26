describe Roi do
  it "has a version number" do
    Roi::VERSION.should_not be_nil
  end

  it "defines a simple Object schema" do
    hash = {}
    schema = Roi.object
    result = schema.validate(hash)

    result.should be_ok
    result.value.should == hash
  end
end
