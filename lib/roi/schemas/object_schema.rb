require 'roi/schemas/base_schema'

module Roi::Schemas
  class ObjectSchema < BaseSchema
    def initialize
      super
      @key_to_schema = {}
      add_test do |value, context|
        if !value.is_a?(Hash)
          Fail(context.error(validator_name: name, message: 'must be a Hash'))
        end
      end
      add_test(&method(:keys_test))
      add_test(&method(:required_keys_test))
    end

    def name
      'object'
    end

    def keys(key_to_schema)
      @key_to_schema = @key_to_schema.merge(key_to_schema)
      self
    end

    private

    def required_keys_test(hash, context)
      errors = @key_to_schema.select do |key, schema|
        schema.required? && !hash.key?(key)
      end.map do |key, schema|
        context.add_path(key).error(
          validator_name: "#{schema.name}.required",
          message: "object must have a value for key #{key.inspect}"
        )
      end

      if errors.any?
        Fail(errors)
      end
    end

    def keys_test(hash, context)
      hash.each do |key, value|
        schema = @key_to_schema[key]
        next if !schema
        validation_result = schema.validate(value, context.add_path(key))
        return validation_result if !validation_result.ok?
      end

      Pass(hash.slice(*@key_to_schema.keys))
    end
  end
end
