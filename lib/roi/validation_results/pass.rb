# typed: true
require 'roi/validation_results'

class Roi::ValidationResults::Pass
  # The object successfully validated and returned by the schema.
  #
  # @return [Object]
  attr_reader :value

  # @return [Boolean]
  attr_reader :pass_early
  alias_method :pass_early?, :pass_early

  def initialize(value, pass_early: false)
    @value = value
    @pass_early = pass_early
  end

  # @return true
  def ok?
    true
  end
end
