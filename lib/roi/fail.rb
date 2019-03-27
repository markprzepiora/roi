require 'roi'

class Roi::Fail < Struct.new(:errors)
  def initialize(*args)
    super
    self.errors ||= []
  end

  def ok?
    false
  end
end
