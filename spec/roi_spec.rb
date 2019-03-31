describe Roi do
  it "has a version number" do
    Roi::VERSION.should_not be_nil
  end

  describe ".define" do
    it "allows a schema to be defined in the context of the Roi object" do
      schema = Roi.define do
        object.keys({
          primes: array.items(int)
        })
      end
      payload = { primes: [2, 3, 5, 7] }
      res = schema.validate(payload)

      res.should be_ok
      res.value.should == payload
    end
  end

  describe ".object(hash)" do
    it "calls Roi.object.keys(hash)" do
      schema = Roi.object({ name: Roi.string })
      res = schema.validate({ name: "Mark" })

      res.should be_ok
      res.value.should == { name: "Mark" }
    end
  end
end
