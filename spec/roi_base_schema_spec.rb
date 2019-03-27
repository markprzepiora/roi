describe Roi::Schemas::BaseSchema do
  it "has a name" do
    described_class.new.name.should == 'base'
  end
end
