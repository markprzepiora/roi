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

  it "does not raise an exception if a test does" do
    schema_class = Class.new(Roi::Schemas::StringSchema) do
      def initialize
        super
        add_test{ fail "this should not be raised" }
      end
    end

    expect {
      schema_class.new.validate("A value")
    }.not_to raise_error
  end

  it "catches the exception and includes the message in the error" do
    schema_class = Class.new(Roi::Schemas::StringSchema) do
      def initialize
        super
        add_test{ fail "this should not be raised" }
      end
    end

    res = schema_class.new.validate("A value")
    res.errors.length.should == 1
    res.errors.first.message.should == "an exception was raised: this should not be raised"
  end
end
