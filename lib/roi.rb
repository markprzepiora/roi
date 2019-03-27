require "roi/version"

module Roi
  def self.string
    Schemas::StringSchema.new
  end

  def self.object
    Schemas::ObjectSchema.new
  end

  class Pass < Struct.new(:value)
    def ok?
      true
    end
  end

  class Fail < Struct.new(:errors)
    def initialize(*args)
      super
      self.errors ||= []
    end

    def ok?
      false
    end
  end

  class ValidationError
    # Examples:
    #
    #     path => ['users', 2, 'name']
    #     validator_name => 'string'
    #     message => 'must be a string'
    #
    #     path => ['age']
    #     validator_name => 'int.min'
    #     message => 'must be at least 21'
    attr_reader :path
    attr_reader :validator_name
    attr_reader :message

    def initialize(path:, validator_name:, message:)
      @path = path
      @validator_name = validator_name
      @message = message
    end
  end

  class ValidationContext
    attr_reader :path, :parent

    def initialize(path:, parent:)
      @path = path || []
      @parent = nil
    end

    def key
      path.last
    end

    def error(validator_name:, message:)
      ValidationError.new(path: path, validator_name: validator_name, message: message)
    end

    def add_path(*append_path)
      self.class.new(path: [*path, *append_path], parent: parent)
    end

    def set_parent(new_parent)
      self.class.new(path: path, parent: new_parent)
    end
  end

  module Schemas
    class BaseSchema
      def initialize
        @tests = []
        @required = false
      end

      def name
        'base'
      end

      def validate(value, context = nil)
        context ||= ValidationContext.new(path: [], parent: nil)
        @tests.each do |test|
          result = test.call(value, context) || Pass(value)
          return result if !result.ok?
          value = result.value
        end

        Pass(value)
      end

      # A schema being "required" or "optional" changes its behaviour when it
      # applies to an object's value. By default, defined key/values can be
      # missing from the validated object.
      #
      # For example:
      #
      #     schema = Roi.object({
      #       name: Roi.string,
      #     })
      #     schema.validate({}).ok?
      #     # => true
      #
      # However, this isn't always what we want. If a key must be present in
      # the validated object, then it can be marked as required.
      #
      #     schema = Roi.object({
      #       name: Roi.string.required,
      #     })
      #     schema.validate({}).ok?
      #     # => false
      def required
        @required = true
        self
      end

      def required?
        !!@required
      end

      private

      def add_test(&block)
        @tests << block
      end

      def Pass(value)
        Pass.new(value)
      end

      def Fail(errors = [])
        Fail.new(errors)
      end
    end

    class StringSchema < BaseSchema
      def initialize
        super
        add_test do |value, context|
          if value.is_a?(String)
            Pass(value)
          else
            Fail([
              context.error(
                validator_name: 'string',
                message: 'must be a string',
              )
            ])
          end
        end
      end

      def name
        'string'
      end
    end

    class ObjectSchema < BaseSchema
      def initialize
        super
        @key_to_schema = {}
        add_test do |value|
          if value.is_a?(Hash)
            Pass(value)
          else
            Fail()
          end
        end
      end

      def name
        'object'
      end

      def keys(key_to_schema)
        @key_to_schema = @key_to_schema.merge(key_to_schema)
        add_test(&method(:keys_test))
        add_test(&method(:required_keys_test))
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
          context = context.add_path(key)
          validation_result = schema.validate(value, context)
          return validation_result if !validation_result.ok?
        end

        Pass(hash.slice(*@key_to_schema.keys))
      end
    end
  end
end
