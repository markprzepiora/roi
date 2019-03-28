require 'roi/schemas/base_schema'

module Roi::Schemas
  class ObjectSchema < BaseSchema
    def initialize
      super
      @key_to_schema = {}
      add_class_test(Hash)
      add_test(&method(:keys_test))
      add_test(&method(:required_keys_test))
    end

    def keys(key_to_schema)
      @key_to_schema = @key_to_schema.merge(key_to_schema)
      self
    end

    def require(key_to_schema)
      key_to_schema = key_to_schema.map do |key, schema|
        [key, schema.required]
      end.to_h
      keys(key_to_schema)
    end

    private

    def required_keys_test(hash, context)
      errors = @key_to_schema.select do |key, schema|
        schema.required? && !hash.key?(key)
      end.map do |key, schema|
        context.add_path(key).error(
          validator_name: "required",
          message: "object must have a value for key #{key.inspect}"
        )
      end

      if errors.any?
        Fail(errors)
      end
    end

    def keys_test(input_hash, context)
      hash = input_hash.dup

      hash.each do |key, value|
        schema = @key_to_schema[key]
        next if !schema
        validation_result = schema.validate(value, context.add_path(key))
        return validation_result if !validation_result.ok?
        hash[key] = validation_result.value
      end

      Pass(hash.slice(*@key_to_schema.keys))
    end

    def name
      'object'
    end
  end
end
