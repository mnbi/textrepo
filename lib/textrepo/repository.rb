module Textrepo
  class Repository
    attr_reader :type, :name

    def initialize(config)
      @type = config[:repository_type]
      @name = config[:repository_name]
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

    # Finds all notes those have timestamps which mathes the specified
    # pattern of timestamp.  Returns an array which contains
    # timestamps.  A pattern must be one of the following:
    #
    #     - yyyymoddhhmiss_lll : whole stamp
    #     - yyyymoddhhmiss     : omit millisecond part
    #     - yyyymodd           : date part only
    #     - yyyymo             : month and year
    #     - yyyy               : year only
    #     - modd               : month and day
    #
    # If `stamp_pattern` is omitted, the recent notes will be listed.
    # Then, how many notes are listed depends on the implementaiton of
    # the concrete repository class.
    def notes(stamp_pattern = nil); []; end

  end

  require_relative 'file_system_repository'

  def init(config)
    type = config[:repository_type]
    cname = type.to_s.split(/_/).map(&:capitalize).join + "Repository"
    repo_generator = "#{cname}.new(config)"

    begin
      eval repo_generator
    rescue 
      raise UnknownRepoTypeError, type.nil? ? "(nil)" : type
    end
  end
  module_function :init
end
