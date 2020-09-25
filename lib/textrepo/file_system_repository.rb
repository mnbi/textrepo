require 'fileutils'

module Textrepo
  # A concrete repository which uses the default file system as a storage.
  class FileSystemRepository < Repository
    attr_reader :path, :extname

    FAVORITE_REPOSITORY_NAME = 'notes'
    FAVORITE_EXTNAME = 'md'

    # `config` must be a Hash object.  It should hold the follwoing
    # values:
    #
    # - :repository_type (:file_system)
    # - :repository_name => basename of the root path for the repository
    # - :repository_base => the parent directory path for the repository
    # - :default_extname => extname for a file stored into in the repository
    #
    # The root path of the repository looks like the following:
    # - config[:repository_base]/config[:repository_name]
    # 
    # Default values are set when `repository_name` and `default_extname`
    # were not defined in `config`.
    def initialize(config)
      super
      base = config[:repository_base]
      @name ||= FAVORITE_REPOSITORY_NAME
      @path = File.expand_path("#{name}", base)
      FileUtils.mkdir_p(@path)
      @extname = config[:default_extname] || FAVORITE_EXTNAME
    end

    #
    # repository operations
    #

    # Creates a file into the repository, which contains the specified
    # text and is associated to the timestamp.
    def create(timestamp, text)
      abs = abspath(timestamp)
      raise DuplicateTimestampError, timestamp if FileTest.exist?(abs)

      write_text(abs, text)
      timestamp
    end

    # Reads the file content in the repository.  Then, returns its
    # content.
    def read(timestamp)
      abs = abspath(timestamp)
      raise MissingTimestampError, timestamp unless FileTest.exist?(abs)
      content = nil
      File.open(abs, 'r') { |f|
        content = f.readlines(chomp: true)
      }
      content
    end

    # Updates the file content in the repository.  A new timestamp
    # will be attached to the text.
    def update(timestamp, text)
      raise EmptyTextError if text.empty?
      org_abs = abspath(timestamp)
      raise MissingTimestampError, timestamp unless FileTest.exist?(org_abs)

      # the text must be stored with the new timestamp
      new_stamp = Timestamp.new(Time.now)
      new_abs = abspath(new_stamp)
      write_text(new_abs, text)

      # delete the original file in the repository
      FileUtils.remove_file(org_abs)

      new_stamp
    end

    # Deletes the file in the repository.
    def delete(timestamp)
      abs = abspath(timestamp)
      raise MissingTimestampError, timestamp unless FileTest.exist?(abs)
      content = read(timestamp)

      FileUtils.remove_file(abs)

      content
    end

    private
    def abspath(timestamp)
      filename = timestamp.to_pathname + ".#{@extname}"
      File.expand_path(filename, @path)
    end

    def write_text(abs, text)
      FileUtils.mkdir_p(File.dirname(abs))
      File.open(abs, 'w') { |f|
        text.each {|line| f.puts(line) }
      }
    end
  end
end
