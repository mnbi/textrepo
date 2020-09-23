module Textrepo
  class Error < StandardError; end

  module ErrMsg
    UNKNOWN_REPO_TYPE   = 'unknown type for repository: %s'
    DUPLICATE_TIMESTAMP = 'duplicate timestamp: %s'
    EMPTY_TEXT          = 'empty text'
    MISSING_TIMESTAMP   = 'missing timestamp: %s'
  end

  class UnknownRepoTypeError < Error
    def initialize(type)
      super(ErrMsg::UNKNOWN_REPO_TYPE % type)
    end
  end

  # Following errors might occur in repository operations:
  # +--------------------------+---------------------+
  # | operation (args)         | error type          |
  # +--------------------------+---------------------+
  # | create (timestamp, text) | Duplicate timestamp |
  # |                          | Empty text          |
  # +--------------------------+---------------------+
  # | read   (timestamp)       | Missing timestamp   |
  # +--------------------------+---------------------+
  # | update (timestamp, text) | Mssing timestamp    |
  # |                          | Empty text          |
  # +--------------------------+---------------------+
  # | delete (timestamp)       | Missing timestamp   |
  # +--------------------------+---------------------+

  class DuplicateTimestampError < Error
    def initialize(timestamp)
      super(ErrMsg::DUPLICATE_TIMESTAMP % timestamp)
    end
  end

  class EmptyTextError < Error
    def initialize
      super(ErrMsg::EMPTY_TEXT)
    end
  end

  class MissingTimestampError < Error
    def initialize(timestamp)
      super(ErrMsg::MISSING_TIMESTAMP % timestamp)
    end
  end

end
