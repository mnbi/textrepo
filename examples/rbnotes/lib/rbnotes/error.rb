module Rbnotes
  class UnknownCommandError < Error
    def initialize(name)
      super "no such command: %s" % name
    end
  end
end
