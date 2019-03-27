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
    attr_reader :path

    def initialize(path)
      @path = path || []
    end

    def error(validator_name:, message:)
      ValidationError.new(path: path, validator_name: validator_name, message: message)
    end

    def add_path(*append_path)
      self.class.new([*path, *append_path])
    end
  end

  module Schemas
    class BaseSchema
      def initialize
        @tests = []
      end

      def validate(value, context = nil)
        context ||= ValidationContext.new([])
        @tests.each do |test|
          result = test.call(value, context)
          return result if !result.ok?
          value = result.value
        end

        Pass(value)
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

      def keys(key_to_schema)
        @key_to_schema = @key_to_schema.merge(key_to_schema)
        add_test(&method(:keys_test))
        self
      end

      private

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
