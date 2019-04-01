require 'roi'

class Roi::Test
  extend Forwardable
  attr_reader :name, :proc

  def initialize(name, proc)
    @name = name
    @proc = proc
  end

  def_delegators :@proc, :call, :to_proc
end
