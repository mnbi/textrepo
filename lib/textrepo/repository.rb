module Textrepo
  class Repository

    include Enumerable

    ##
    # Repository type.  It specifies which concrete repository class
    # will instantiated.  For example, the type `:file_system` specifies
    # `FileSystemRepository`.

    attr_reader :type

    ##
    # Repository name.  The usage of the value of `name` depends on a
    # concrete repository class.  For example, `FileSystemRepository`
    # uses it as a part of the repository path.

    attr_reader :name

    ##
    # Create a new repository.  The argument must be an object which
    # can be accessed like a Hash object.

    def initialize(conf)
      @type = conf[:repository_type]
      @name = conf[:repository_name]
    end

    ##
    # Stores text data into the repository with the specified timestamp.
    # Returns the timestamp.
    #
    # :call-seq:
    #     create(Timestamp, Array) -> Timestamp

    def create(timestamp, text); timestamp; end

    ##
    # Reads text data from the repository, which is associated to the
    # timestamp.  Returns an array which contains the text.
    #
    # :call-seq:
    #     read(Timestamp) -> Array

    def read(timestamp); []; end

    ##
    # Updates the content with given text in the repository, which is
    # associated to the given Timestamp object.  Returns the Timestamp
    # newly generated during the execution.
    #
    # When true is passed as the third argument, keeps the Timestamp
    # unchanged, though updates the content.  Then, returns the given
    # Timestamp object.
    #
    # If the given Timestamp object is not existed as a Timestamp
    # attached to text in the repository, raises
    # MissingTimestampError.
    #
    # If the given text is empty, raises EmptyTextError.
    #
    # If the given text is identical to the text in the repository,
    # does nothing.  Returns the given timestamp itself.
    #
    # :call-seq:
    #     update(Timestamp, Array, true or false) -> Timestamp

    def update(timestamp, text, keep_stamp = false); timestamp; end

    ##
    # Deletes the content in the repository, which is associated to
    # the timestamp.  Returns an array which contains the deleted text.
    #
    # :call-seq:
    #     delete(Timestamp) -> Array

    def delete(timestamp); []; end

    ##
    # Finds all entries of text those have timestamps which mathes the
    # specified pattern of timestamp.  Returns an array which contains
    # instances of Timestamp.  If none of text was found, an empty
    # array would be returned.
    #
    #  A pattern must be one of the following:
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
    #
    # :call-seq:
    #     entries(String) -> Array of Timestamp instances

    def entries(stamp_pattern = nil); []; end

    ##
    # Check the existence of text which is associated with the given
    # timestamp.
    #
    # :call-seq:
    #     exist?(Timestamp) -> true or false

    def exist?(timestamp); false; end

    ##
    # Searches a pattern (word or regular expression) in text those
    # matches to a given timestamp pattern.  Returns an Array of
    # search results.  If no match, returns an empty Array.
    #
    # See the document for Repository#entries about a timestamp
    # pattern.  When nil is passed as a timestamp pattern, searching
    # applies to all text in the repository.
    #
    # Each entry of the result Array is constructed from 3 items, (1)
    # timestamp (Timestamp), (2) line number (Integer), (3) matched
    # line (String).
    #
    # :call-seq:
    #     search(String for pattern, String for Timestamp pattern) -> Array

    def search(pattern, stamp_pattern = nil); []; end

    ##
    # Calls the given block once for each pair of timestamp and text
    # in self, passing those pair as parameter.  Returns the
    # repository itself.
    #
    # If no block is given, an Enumerator is returned.

    def each(&block)
      if block.nil?
        entries.lazy.map { |timestamp| pair(timestamp) }.to_enum(:each)
      else
        entries.each { |timestamp| yield pair(timestamp) }
        self
      end
    end

    alias each_pair each

    ##
    # Calls the given block once for each timestamp in self, passing
    # the timestamp as a parameter.  Returns the repository itself.
    #
    # If no block is given, an Enumerator is returned.

    def each_key(&block)
      if block.nil?
        entries.to_enum(:each)
      else
        entries.each(&block)
      end
    end

    alias each_timestamp each_key

    ##
    # Calls the given block once for each timestamp in self, passing
    # the text as a parameter.  Returns the repository itself.
    #
    # If no block is given, an Enumerator is returned.

    def each_value(&block)
      if block.nil?
        entries.lazy.map { |timestamp| read(timestamp) }.to_enum(:each)
      else
        entries.each { |timestamp| yield read(timestamp) }
      end
    end

    alias each_text each_value

    # :stopdoc:

    private

    def pair(timestamp)
      [timestamp, read(timestamp)]
    end

    # :startdoc:
  end

  require_relative 'file_system_repository'

  ##
  # Returns an instance which derived from Textrepo::Repository class.
  # `conf` must be an object which can be accessed like a Hash object.
  # And it must also has a value of `:repository_type` and
  # `:repository_name` at least.  Some concrete class derived from
  # Textrepo::Repository may require more key-value pairs in `conf`.

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
