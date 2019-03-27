describe Roi do
  it "has a version number" do
    Roi::VERSION.should_not be_nil
  end

  describe ".<schema>.allow" do
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

  describe ".<schema>.invalid" do
    include_examples "passing and failing values",
      schema: 'Roi.int.min(10).invalid(12)',
      passing_values: [10, 11, 13],
      failing_values: [12]
  end

  describe "errors" do
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
      error.message.should == 'must be a string'
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
      error.message.should == 'must be a string'
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
      error.message.should == 'must be a string'
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

  context "given a complete example (user endpoint)" do
    let(:user_schema) do
      Roi.object.keys({
        id: Roi.int.required.min(1),
        first_name: Roi.string.required,
        company: Roi.object.keys({
          name: Roi.string.required,
        }).or_nil.required,
        accounts: Roi.array.items(Roi.object.keys({
          id: Roi.int.required,
          name: Roi.string.required,
        }))
      })
    end
    let(:schema) { Roi.object.keys(user: user_schema.required) }

    it "validates a complete, passing example" do
      payload = {
        user: {
          id: 123,
          first_name: "Mark",
          company: {
            name: "Biocyte",
          },
          accounts: [
            { id: 1, name: "My account" },
            { id: 2, name: "Another account" },
          ],
        },
      }
      result = schema.validate(payload)

      result.should be_ok
      result.value.should == payload
    end

    it "validates an alternative passing example" do
      payload = {
        user: {
          id: 123,
          first_name: "Mark",
          company: nil,
          accounts: [
            { id: 1, name: "My account" },
            { id: 2, name: "Another account" },
          ],
        },
      }
      result = schema.validate(payload)

      result.should be_ok
      result.value.should == payload
    end

    it "gives a correct error given an invalid account" do
      payload = {
        user: {
          id: 123,
          first_name: "Mark",
          company: nil,
          accounts: [
            { id: 1, name: "My account" },
            { id: nil, name: "Another account" },
          ],
        },
      }
      result = schema.validate(payload)

      result.should_not be_ok
      result.errors.count.should == 1

      error = result.errors.first
      error.path.should == [:user, :accounts, 1, :id]
    end

    it "gives a correct error given a missing company" do
      payload = {
        user: {
          id: 123,
          first_name: "Mark",
          accounts: [],
        },
      }
      result = schema.validate(payload)

      result.should_not be_ok
      result.errors.count.should == 1

      error = result.errors.first
      error.path.should == [:user, :company]
    end

    it "gives a correct error given a missing user" do
      # Imagine the typo below
      payload = {
        users: {},
      }
      result = schema.validate(payload)

      result.should_not be_ok
      result.errors.count.should == 1

      error = result.errors.first
      error.path.should == [:user]
      error.validator_name.should == 'object.required'
    end
  end

  context "given a recursive schema" do
    let(:schema) do
      account_schema = Roi.object.keys({
        name: Roi.string.required,
      })
      account_schema.keys({
        child_accounts: Roi.array.items(account_schema)
      })
    end

    it "validates a simple, non-recursive payload" do
      payload = {
        name: "Account 1",
        child_accounts: [],
      }
      result = schema.validate(payload)

      result.should be_ok
      result.value.should == payload
    end

    it "validates a simple payload (one level of children)" do
      payload = {
        name: "Account 1",
        child_accounts: [
          {
            name: "Account 1A",
            child_accounts: [],
          }
        ],
      }
      result = schema.validate(payload)

      result.should be_ok
      result.value.should == payload
    end

    it "validates a simple payload (two levels of children)" do
      payload = {
        name: "Account 1",
        child_accounts: [
          {
            name: "Account 1A",
            child_accounts: [
              {
                name: "Account 1AA",
                child_accounts: [],
              }
            ],
          }
        ],
      }
      result = schema.validate(payload)

      result.should be_ok
      result.value.should == payload
    end

    it "rejects a payload with an error a few levels deep" do
      payload = {
        name: "Account 1",
        child_accounts: [
          {
            name: "Account 1A",
            child_accounts: [
              {
                name: nil,
                child_accounts: [],
              }
            ],
          }
        ],
      }
      result = schema.validate(payload)

      result.should_not be_ok
      result.errors.length.should == 1
      result.errors.first.path.should == [:child_accounts, 0, :child_accounts, 0, :name]
    end
  end
end
