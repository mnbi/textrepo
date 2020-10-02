require "textrepo"

module Rbnotes
  class Error < StandardError; end

  require_relative "rbnotes/version"
  require_relative "rbnotes/error"
  require_relative "rbnotes/commands"
  require_relative "rbnotes/cli"
end
