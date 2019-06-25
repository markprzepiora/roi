# typed: true

require 'roi/validation_results'
require 'sorbet-runtime'

class Roi::ValidationResults::Fail
  extend T::Sig

  # @return [Array<Roi::ValidationError>]
  attr_reader :errors

  sig{ params(errors: T::Array[Roi::ValidationError] ).void }
  def initialize(errors = [])
    @errors = errors
  end

  sig{ returns(T::Boolean) }
  # @return false
  def ok?
    false
  end
end
