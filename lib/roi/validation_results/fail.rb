require 'roi/validation_results'

class Roi::ValidationResults::Fail
  # @return [Array<Roi::ValidationError>]
  attr_reader :errors

  def initialize(errors = [])
    @errors = errors
  end

  # @return false
  def ok?
    false
  end
end
