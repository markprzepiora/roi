require 'roi/validation_results'

class Roi::ValidationResults::Fail < Struct.new(:errors)
  def initialize(*args)
    super
    self.errors ||= []
  end

  def ok?
    false
  end
end
