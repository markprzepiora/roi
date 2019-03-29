require 'roi'

class Roi::Test
  extend Forwardable
  attr_reader :name, :proc

  def initialize(name, proc)
    @name = name
    @proc = proc
  end

  def in_context(schema, context)
    TestContext.new(schema, self, context)
  end

  def_delegator :@proc, :call

  class TestContext < SimpleDelegator
    def initialize(schema_instance, test, context)
      @__test__ = test
      @__context__ = context
      schema_instance.instance_variables.each do |name|
        instance_variable_set(name, schema_instance.instance_variable_get(name))
      end
      super(schema_instance)
    end

    def call(*args, &block)
      @__test__.call(*args, &block)
    end

    def error(message)
      @__context__.error(validator_name: @__test__.name, message: message)
    end
  end
end
