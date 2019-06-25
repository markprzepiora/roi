# typed: true

require 'roi/validation_results'
require 'sorbet-runtime'

class Roi::ValidationResults::Pass
  extend T::Sig

  # The object successfully validated and returned by the schema.
  #
  # @return [Object]
  attr_reader :value

  # @return [Boolean]
  attr_reader :pass_early
  alias_method :pass_early?, :pass_early

  sig{ params(value: T.untyped, pass_early: T::Boolean).void }
  def initialize(value, pass_early: false)
    @value = value
    @pass_early = pass_early
  end

  # @return true
  sig{ returns(T::Boolean) }
  def ok?
    true
  end
end
