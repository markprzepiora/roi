describe 'Schema errors' do
  it "returns an error when a validation fails" do
    value = { name: 123 }
    schema = Roi.object.keys({
      name: Roi.string
    })
    result = schema.validate(value)

    result.should_not be_ok
    result.errors.length.should == 1
  end

  it "creates an error with a path and other information" do
    value = { name: 123 }
    schema = Roi.object.keys({
      name: Roi.string
    })
    result = schema.validate(value)

    result.should_not be_ok
    error = result.errors.first
    error.path.should == [:name]
    error.validator_name.should == 'string'
    error.message.should == 'must be a String'
  end

  it "creates an error with a path and other information" do
    value = { first_name: 123 }
    schema = Roi.object.keys({
      first_name: Roi.string
    })
    result = schema.validate(value)

    result.should_not be_ok
    error = result.errors.first
    error.path.should == [:first_name]
    error.validator_name.should == 'string'
    error.message.should == 'must be a String'
  end

  it "creates an error with a nested path" do
    value = { user: { first_name: 123 } }
    schema = Roi.object.keys({
      user: Roi.object.keys({
        first_name: Roi.string,
      }),
    })
    result = schema.validate(value)

    result.should_not be_ok
    error = result.errors.first
    error.path.should == [:user, :first_name]
    error.validator_name.should == 'string'
    error.message.should == 'must be a String'
  end

  it "raises uncaught exceptions from within tests" do
    schema_class = Class.new(Roi::Schemas::StringSchema) do
      def initialize
        super
        add_test('fail', :test_fail)
      end

      def test_fail(*args)
        fail "this should be re-raised" 
      end
    end

    expect {
      schema_class.new.validate("A value")
    }.to raise_error("this should be re-raised")
  end
end
