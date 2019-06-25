# typed: false
require 'set'
require 'roi/schemas'
require 'roi/validation_context'
require 'roi/validation_results/pass'
require 'roi/validation_results/fail'
require 'roi/test'
require 'sorbet-runtime'

module Roi::Schemas
  class BaseSchema
    extend T::Sig

    def initialize
      @tests = []

      @required = false
      @valids = Set.new
      @invalids = Set.new
      @must_bes = []
      @must_not_bes = []
      @klass = nil

      add_test("invalid", :test_invalids)
      add_test("valid", :test_valids)
      add_test("#{name}.cast", :test_cast_value_wrapper)
      add_test("must_be", :test_must_be)
      add_test("must_not_be", :test_must_not_be)
      add_test(name, :test_class)
    end

    sig{
      params(value: T.untyped, context: T.nilable(Roi::ValidationContext)).
      returns(T.any(Roi::ValidationResults::Pass, Roi::ValidationResults::Fail))
    }
    # @return [Roi::ValidationResults::Pass, Roi::ValidationResults::Fail]
    def validate(value, context = nil)
      context ||= Roi::ValidationContext.new(path: [])

      @tests.each do |test|
        test_context = context.set_validator_name(test.name)
        result = run_test(test, value, test_context)

        return result if !result.ok? || result.pass_early?

        value = result.value
      end

      Pass(value)
    end

    sig{ returns(Roi::Schemas::BaseSchema) }
    # A schema being "required" or "optional" changes its behaviour when it
    # applies to an object's value. By default, defined key/values can be
    # missing from the validated object.
    #
    # For example:
    #
    #     schema = Roi.object.keys({
    #       name: Roi.string,
    #     })
    #     schema.validate({}).ok?
    #     # => true
    #
    # However, this isn't always what we want. If a key must be present in
    # the validated object, then it can be marked as required.
    #
    #     schema = Roi.object.keys({
    #       name: Roi.string.required,
    #     })
    #     schema.validate({}).ok?
    #     # => false
    #
    # @return self
    def required
      @required = true
      self
    end

    sig{ params(valids: T.untyped).returns(Roi::Schemas::BaseSchema) }
    # Explicitly whitelist one or more values, no matter what any other
    # requirements (except the `invalids` blacklist) say.
    #
    # @example
    #   schema = Roi.int.min(100).allow(0)
    #   schema.validate(100).ok? # => true
    #   schema.validate(99).ok? # => false
    #   schema.validate(0).ok? # => true
    #
    # @param valids [Array] The whitelisted values.
    #
    # @return self
    def allow(*valids)
      @valids = @valids | valids
      self
    end

    sig{ returns(Roi::Schemas::BaseSchema) }
    # Allow the value to be nil.
    #
    # @example
    #   schema = Roi.string.or_nil
    #   schema.validate("test").ok? # => true
    #   schema.validate(nil).ok? # => true
    def or_nil
      allow(nil)
    end

    # Blacklist one or more values.
    #
    # @example
    #   schema = Roi.string.invalid('bar')
    #   schema.validate('foo').ok? # => true
    #   schema.validate('bar').ok? # => false
    #
    # @param invalids [Array] The blacklisted values.
    #
    # @return self
    def invalid(*invalids)
      @invalids = @invalids | invalids
      self
    end

    # The value must return a truthy value when called with the method named by
    # `method_name`.
    #
    # If the value does not respond to the given method name, then it is
    # rejected as well.
    #
    # If the method raises an exception, then this also counts as a rejection.
    #
    # @param method_name [Symbol] 
    #
    # @example Only accept even integers.
    #   schema = Roi.int.must_be(:even?)
    #   schema.validate(2).ok? # => true
    #   schema.validate(3).ok? # => false
    #
    # @return self
    def must_be(method_name)
      @must_bes << method_name
      self
    end

    # The value must not return a truthy value when called with the method
    # named by `method_name`.
    #
    # If the value does not respond to the given method name, then it passes.
    #
    # If the method raises an exception, then this also counts as a rejection.
    #
    # @param method_name [Symbol] 
    #
    # @example Only accept odd integers.
    #   schema = Roi.int.must_not_be(:even?)
    #   schema.validate(1).ok? # => true
    #   schema.validate(2).ok? # => false
    #
    # @return self
    def must_not_be(method_name)
      @must_not_bes << method_name
      self
    end

    def cast
      @cast = true
      self
    end

    private

    def cast_value(value, context)
    end

    def test_invalids(value, context)
      # Matches of 'invalids' values override all other tests (and valids),
      # since this is meant to be a blacklist.
      if @invalids.include?(value)
        Fail(context.error("#{value.inspect} is invalid for this field"))
      end
    end

    def test_valids(value, context)
      # Matches of 'valids' values override failing tests, since the intention
      # is to allow restrictions to be overruled with a whitelist.
      if @valids.include?(value)
        Pass(value, pass_early: true)
      end
    end

    def test_cast_value_wrapper(value, context)
      cast_value(value, context) if @cast
    end

    def test_must_be(value, context)
      @must_bes.each do |method_name|
        error = context.error("##{method_name} must be true")
        begin
          if !value.respond_to?(method_name) || !value.public_send(method_name)
            return Fail([error])
          end
        rescue StandardError => e
          return Fail([error])
        end
      end
    end

    def test_must_not_be(value, context)
      @must_not_bes.each do |method_name|
        error = context.error("##{method_name} must be false")
        begin
          if value.respond_to?(method_name) && value.public_send(method_name)
            return Fail([error])
          end
        rescue StandardError => e
          return Fail([error])
        end
      end
    end

    sig{ params(test_name: String, method_name: Symbol).returns(Roi::Schemas::BaseSchema) }
    def add_test(test_name, method_name)
      @tests << Roi::Test.new(test_name, method_name)
      self
    end

    sig{ params(klass: Class, message: T.nilable(String)).returns(Roi::Schemas::BaseSchema) }
    def add_class_test(klass, message = nil)
      @klass = {
        klass: klass,
        message: message || "must be a #{klass.name}",
      }
      self
    end

    def test_class(value, context)
      return if !@klass

      klass = @klass[:klass]
      message = @klass[:message]

      if !value.is_a?(klass)
        Fail(context.error(message))
      end
    end

    def Pass(*args)
      Roi::ValidationResults::Pass.new(*args)
    end

    sig{
      params(errors: T.any(T::Array[Roi::ValidationError], Roi::ValidationError)).
      returns(Roi::ValidationResults::Fail)
    }
    def Fail(errors = [])
      errors = Array(errors)
      Roi::ValidationResults::Fail.new(errors)
    end

    sig{
      params(test: Roi::Test, value: T.untyped, context: Roi::ValidationContext).
      returns(T.any(Roi::ValidationResults::Pass, Roi::ValidationResults::Fail))
    }
    def run_test(test, value, context)
      result = test.run(self, value, context)

      case result
      when Roi::ValidationResults::Pass, Roi::ValidationResults::Fail then result
      else Pass(value)
      end
    end

    protected

    sig{ returns(T::Boolean) }
    def required?
      !!@required
    end
  end
end
