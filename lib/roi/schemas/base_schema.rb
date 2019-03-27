require 'set'
require 'roi/schemas'
require 'roi/validation_context'
require 'roi/pass'
require 'roi/fail'

module Roi::Schemas
  class BaseSchema
    def initialize
      @tests = []
      @required = false
      @valids = Set.new
      @invalids = Set.new
    end

    def name
      'base'
    end

    def validate(value, context = nil)
      context ||= Roi::ValidationContext.new(path: [], parent: nil)

      # Matches of 'invalids' values override all other tests (and valids),
      # since this is meant to be a blacklist.
      if @invalids.include?(value)
        return Fail([
          context.error(
            validator_name: "#{name}.invalid",
            message: "#{value.inspect} is invalid for this field")
        ])
      end

      # Matches of 'valids' values override failing tests, since the intention
      # is to allow restrictions to be overruled with a whitelist.
      if @valids.include?(value)
        return Pass(value)
      end

      @tests.each do |test|
        result = begin
          test.call(value, context) || Pass(value)
        rescue StandardError => e
          Fail([
            context.error(
              validator_name: "uncaught_exception",
              message: "an exception was raised: #{e.message}"
            )
          ])
        end
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

    def allow(*valids)
      valids.each do |value|
        @valids.add(value)
      end
      self
    end

    def or_nil
      allow(nil)
    end

    def invalid(*invalids)
      invalids.each do |value|
        @invalids.add(value)
      end
      self
    end

    def must_be(method_name)
      add_test do |value, context|
        error = context.error(
          validator_name: "#{name}.must_be",
          message: "##{method_name} must be true")
        begin
          if !value.respond_to?(method_name) || !value.public_send(method_name)
            Fail([error])
          end
        rescue StandardError => e
          Fail([error])
        end
      end
    end

    def must_not_be(method_name)
      add_test do |value, context|
        error = context.error(
          validator_name: "#{name}.must_not_be",
          message: "##{method_name} must be false")
        begin
          if value.respond_to?(method_name) && value.public_send(method_name)
            Fail([error])
          end
        rescue StandardError => e
          Fail([error])
        end
      end
    end

    private

    def add_test(&block)
      @tests << block
      self
    end

    def Pass(value)
      Roi::Pass.new(value)
    end

    def Fail(errors = [])
      Roi::Fail.new(errors)
    end
  end
end
