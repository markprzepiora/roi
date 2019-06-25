# typed: true

require 'roi'
require 'sorbet-runtime'

class Roi::Test
  extend T::Sig
  extend Forwardable
  attr_reader :name, :method_name

  sig{ params(name: String, method_name: Symbol).void }
  def initialize(name, method_name)
    @name = name
    @method_name = method_name
  end

  sig{
    params(schema: Roi::Schemas::BaseSchema, value: T.untyped, context: Roi::ValidationContext).
    returns(T.any(Roi::ValidationResults::Pass, Roi::ValidationResults::Fail, T.untyped))
  }
  def run(schema, value, context)
    schema.send(method_name, value, context)
  end
end
