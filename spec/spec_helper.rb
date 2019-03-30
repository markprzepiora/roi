require "bundler/setup"

require 'pry'
require 'simplecov'
SimpleCov.start

require "roi"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

shared_examples "passing and failing values" do |schema: nil, passing_values: [], failing_values: []|
  fail ArgumentError, "must specify a schema" if !schema

  schema_string = schema

  describe "schema #{schema_string}" do
    passing_values.each do |input_value|
      it "validates #{input_value.inspect}" do
        schema = eval(schema_string)
        result = schema.validate(input_value)
        result.should be_ok
      end
    end

    failing_values.each do |input_value|
      it "rejects #{input_value.inspect}" do
        schema = eval(schema_string)
        result = schema.validate(input_value)
        result.should_not be_ok
      end
    end
  end
end

shared_examples "filters input value" do |schema: :__NONE__, input_value: :__NONE__, output_value: :__NONE__|
  fail ArgumentError, "must specify a schema" if schema == :__NONE__
  fail ArgumentError, "must specify an input_value" if input_value == :__NONE__
  fail ArgumentError, "must specify an output_value" if output_value == :__NONE__

  schema_string = schema

  describe "schema #{schema_string} on input #{input_value.inspect}" do
    let(:real_schema) { eval(schema_string) }
    let(:result) { real_schema.validate(input_value) }

    it "passes" do
      result.should be_ok
    end

    it "returns the value #{output_value.inspect}" do
      result.value.should == output_value
    end

    it "returns a #{output_value.class}" do
      result.value.class.should == output_value.class
    end
  end
end

shared_examples "error message" do |schema: :__NONE__, input_value: :__NONE__, error_message: nil, error_path: nil, error_validator_name: nil|
  fail ArgumentError, "must specify a schema" if schema == :__NONE__
  fail ArgumentError, "must specify an input_value" if input_value == :__NONE__

  schema_string = schema

  describe "schema #{schema_string} on input #{input_value.inspect}" do
    let(:real_schema) { eval(schema_string) }
    let(:result) { real_schema.validate(input_value) }
    let(:errors) { result.errors }

    it "rejects" do
      result.should_not be_ok
    end

    it "has an error" do
      errors.should_not be_empty
    end

    if error_message
      it "has error #{error_message.inspect}" do
        errors.first.message.should match(error_message)
      end
    end

    if error_path
      it "has error path #{error_path.inspect}" do
        errors.first.path.should == error_path
      end
    end

    if error_validator_name
      it "has error validator name #{error_validator_name.inspect}" do
        errors.first.validator_name.should == error_validator_name
      end
    end
  end
end
