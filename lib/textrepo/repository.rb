module Textrepo
  class Repository
    attr_reader :type, :name

    def initialize(conf)
      @type = conf[:repository_type]
      @name = conf[:repository_name]
    end

    # Stores text data into the repository with the specified timestamp.
    # Returns the timestamp.
    def create(timestamp, text); timestamp; end

    # Reads text data from the repository, which is associated to the
    # timestamp.  Returns an array which contains the text.
    def read(timestamp); []; end

    # Updates the content with text in the repository, which is
    # associated to the timestamp.  Returns the timestamp.
    def update(timestamp, text); timestamp; end

    # Deletes the content in the repository, which is associated to
    # the timestamp.  Returns an array which contains the deleted text.
    def delete(timestamp); []; end

    # Finds all entries of text those have timestamps which mathes the
    # specified pattern of timestamp.  Returns an array which contains
    # timestamps.  A pattern must be one of the following:
    #
    #     - yyyymoddhhmiss_lll : whole stamp
    #     - yyyymoddhhmiss     : omit millisecond part
    #     - yyyymodd           : date part only
    #     - yyyymo             : month and year
    #     - yyyy               : year only
    #     - modd               : month and day
    #
    # If `stamp_pattern` is omitted, the recent entries will be listed.
    # Then, how many entries are listed depends on the implementaiton
    # of the concrete repository class.
    def entries(stamp_pattern = nil); []; end

  end

  require_relative 'file_system_repository'

  # Returns an instance which derived from Textrepo::Repository class.
  # `conf` must be a Hash object which has a value of
  # `:repository_type` and `:repository_name` at least.  Some concrete
  # class derived from Textrepo::Repository may require more key-value
  # pairs in `conf`.
  def init(conf)
    type = conf[:repository_type]
    klass_name = type.to_s.split(/_/).map(&:capitalize).join + "Repository"
    if Textrepo.const_defined?(klass_name)
      klass = Textrepo.const_get(klass_name, false)
    else
      raise UnknownRepoTypeError, type.nil? ? "(nil)" : type
    end
    klass.new(conf)
  end
  module_function :init
end
