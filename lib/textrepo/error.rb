module Textrepo

  ##
  # Following errors might occur in repository operations:
  #   +--------------------------+---------------------+
  #   | operation (args)         | error type          |
  #   +--------------------------+---------------------+
  #   | create (timestamp, text) | Duplicate timestamp |
  #   |                          | Empty text          |
  #   +--------------------------+---------------------+
  #   | read   (timestamp)       | Missing timestamp   |
  #   +--------------------------+---------------------+
  #   | update (timestamp, text) | Mssing timestamp    |
  #   |                          | Empty text          |
  #   +--------------------------+---------------------+
  #   | delete (timestamp)       | Missing timestamp   |
  #   +--------------------------+---------------------+

  class Error < StandardError; end

  # :stopdoc:
  module ErrMsg
    UNKNOWN_REPO_TYPE   = 'unknown type for repository: %s'
    DUPLICATE_TIMESTAMP = 'duplicate timestamp: %s'
    EMPTY_TEXT          = 'empty text'
    MISSING_TIMESTAMP   = 'missing timestamp: %s'
    INVALID_TIMESTAMP_STRING = "invalid string as timestamp: %s"
  end
  # :startdoc:

  ##
  # An error raised if unknown type was specified as the repository
  # type.

  class UnknownRepoTypeError < Error
    def initialize(type)
      super(ErrMsg::UNKNOWN_REPO_TYPE % type)
    end
  end

  ##
  # An error raised if the specified timestamp has already exist in
  # the repository.

  class DuplicateTimestampError < Error
    def initialize(timestamp)
      super(ErrMsg::DUPLICATE_TIMESTAMP % timestamp)
    end
  end

  ##
  # An error raised if the given text is empty.

  class EmptyTextError < Error
    def initialize
      super(ErrMsg::EMPTY_TEXT)
    end
  end

  ##
  # An error raised if the given timestamp has not exist in the
  # repository.

  class MissingTimestampError < Error
    def initialize(timestamp)
      super(ErrMsg::MISSING_TIMESTAMP % timestamp)
    end
  end

  ##
  # An error raised if an argument is invalid to convert a
  # Textrepo::Timestamp object.

  class InvalidTimestampStringError < Error
    def initialize(str)
      super(ErrMsg::INVALID_TIMESTAMP_STRING % str)
    end
  end

end
