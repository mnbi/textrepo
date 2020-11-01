require 'fileutils'
require "open3"

module Textrepo

  ##
  # A concrete class which implements Repository interfaces.  This
  # repository uses the default file system of the operating system as
  # a text storage.

  class FileSystemRepository < Repository

    ##
    # Repository root.

    attr_reader :path

    ##
    # Extension of notes sotres in the repository.

    attr_reader :extname

    ##
    # Searcher program name.

    attr_reader :searcher

    ##
    # An array of options to pass to the searcher program.

    attr_reader :searcher_options

    ##
    # Default name for the repository which uses when no name is
    # specified in the configuration settings.

    FAVORITE_REPOSITORY_NAME = 'notes'

    ##
    # Default extension of notes which uses when no extname is
    # specified in the configuration settings.

    FAVORITE_EXTNAME = 'md'

    ##
    # Default searcher program to search text in the repository.

    FAVORITE_SEARCHER = 'grep'

    ##
    # Creates a new repository object.  The argument, `conf` must be a
    # Hash object.  It should hold the follwoing values:
    #
    # - MANDATORY:
    #   - :repository_type => `:file_system`
    #   - :repository_base => the parent directory path for the repository
    # - OPTIONAL: (if not specified, default values are used)
    #   - :repository_name => basename of the root path for the repository
    #   - :default_extname => extname for a file stored into in the repository
    #   - :searcher => a program to search like `grep`
    #   - :searcher_options => an Array of option to pass to the searcher
    #
    # The root path of the repository looks like the following:
    # - conf[:repository_base]/conf[:repository_name]
    # 
    # Default values are set when `:repository_name` and `:default_extname`
    # were not defined in `conf`.
    #
    # Be careful to set `:searcher_options`, it must be to specify the
    # searcher behavior equivalent to `grep` with "-inR".  The default
    # value for the searcher options is defined for BSD grep (default
    # grep on macOS), GNU grep, and ripgrep (aka rg).  They are:
    #
    #   "grep"   => ["-i", "-n", "-R", "-E"]
    #   "egrep"  => ["-i", "-n", "-R"]
    #   "ggrep"  => ["-i", "-n", "-R", "-E"]
    #   "gegrep" => ["-i", "-n", "-R"]
    #   "rg"     => ["-S", "-n", "--no-heading", "--color", "never"]
    #
    # If use those 3 searchers, it is not recommended to set
    # `:searcher_options`.  The default value works well in
    # `textrepo`.
    #
    # :call-seq:
    #     new(Hash or Hash like object) -> FileSystemRepository

    def initialize(conf)
      super
      base = conf[:repository_base]
      @name ||= FAVORITE_REPOSITORY_NAME
      @path = File.expand_path("#{name}", base)
      FileUtils.mkdir_p(@path)
      @extname = conf[:default_extname] || FAVORITE_EXTNAME
      @searcher = find_searcher(conf[:searcher])
      @searcher_options = conf[:searcher_options]
    end

    ##
    # Creates a file into the repository, which contains the specified
    # text and is associated to the timestamp.
    #
    # :call-seq:
    #     create(Timestamp, Array) -> Timestamp

    def create(timestamp, text)
      abs = abspath(timestamp)
      raise DuplicateTimestampError, timestamp if FileTest.exist?(abs)
      raise EmptyTextError if text.nil? || text.empty?

      write_text(abs, text)
      timestamp
    end

    ##
    # Reads the file content in the repository.  Then, returns its
    # content.
    #
    # :call-seq:
    #     read(Timestamp) -> Array

    def read(timestamp)
      abs = abspath(timestamp)
      raise MissingTimestampError, timestamp unless FileTest.exist?(abs)
      content = nil
      File.open(abs, 'r') { |f|
        content = f.readlines(chomp: true)
      }
      content
    end

    ##
    # Updates the file content in the repository.  A new timestamp
    # will be attached to the text.
    #
    # :call-seq:
    #     update(Timestamp, Array) -> Timestamp

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

    ##
    # Deletes the file in the repository.
    #
    # :call-seq:
    #     delete(Timestamp) -> Array

    def delete(timestamp)
      abs = abspath(timestamp)
      raise MissingTimestampError, timestamp unless FileTest.exist?(abs)
      content = read(timestamp)

      FileUtils.remove_file(abs)

      content
    end

    ##
    # Finds entries of text those timestamp matches the specified pattern.
    #
    # :call-seq:
    #     entries(String = nil) -> Array of Timestamp instances

    def entries(stamp_pattern = nil)
      results = []

      case stamp_pattern.to_s.size
      when "yyyymoddhhmiss_lll".size
        stamp = Timestamp.parse_s(stamp_pattern)
        if exist?(stamp)
          results << stamp
        end
      when 0, "yyyymoddhhmiss".size, "yyyymodd".size
        results += find_entries(stamp_pattern)
      when 4                    # "yyyy" or "modd"
        pat = nil
        # The following distinction is practically correct, but not
        # perfect.  It simply assumes that a year is greater than
        # 1231.  For, a year before 1232 is too old for us to create
        # any text (I believe...).
        if stamp_pattern.to_i > 1231
          # yyyy
          pat = stamp_pattern
        else
          # modd
          pat = "*#{stamp_pattern}"
        end
        results += find_entries(pat)
      end

      results
    end

    ##
    # Check the existence of text which is associated with the given
    # timestamp.
    #
    # :call-seq:
    #     exist?(Timestamp) -> true or false

    def exist?(timestamp)
      FileTest.exist?(abspath(timestamp))
    end

    ##
    # Searches a pattern in all text.  The given pattern is a word to
    # search or a regular expression.  The pattern would be passed to
    # a searcher program as it passed.
    #
    # See the document for Textrepo::Repository#search to know about
    # the search result.
    #
    # :call-seq:
    #     search(String for pattern, String for Timestamp pattern) -> Array

    def search(pattern, stamp_pattern = nil)
      result = nil
      if stamp_pattern.nil?
        result = invoke_searcher_at_repo_root(@searcher, pattern)
      else
        result = invoke_searcher_for_entries(@searcher, pattern, entries(stamp_pattern))
      end
      construct_search_result(result)
    end

    # :stopdoc:

    private
    def abspath(timestamp)
      filename = timestamp_to_pathname(timestamp) + ".#{@extname}"
      File.expand_path(filename, @path)
    end

    #  %Y   %m %d %H %M %S  suffix        %Y/%m/  %Y%m%d%H%M%S %L
    # "2020-12-30 12:34:56  (0 | nil)" => "2020/12/20201230123456"
    # "2020-12-30 12:34:56  (7)"       => "2020/12/20201230123456_007"
    def timestamp_to_pathname(timestamp)
      yyyy, mo = Timestamp.split_stamp(timestamp.to_s)[0..1]
      File.join(yyyy, mo, timestamp.to_s)
    end

    def write_text(abs, text)
      FileUtils.mkdir_p(File.dirname(abs))
      File.open(abs, 'w') { |f|
        text.each {|line| f.puts(line) }
      }
    end

    def timestamp_str(text_path)
      File.basename(text_path).delete_suffix(".#{@extname}")
    end

    def find_entries(stamp_pattern)
      Dir.glob("#{@path}/**/#{stamp_pattern}*.#{@extname}").map { |e|
        begin
          Timestamp.parse_s(timestamp_str(e))
        rescue InvalidTimestampStringError => _
          # Just ignore the erroneous entry, since it is not a text in
          # the repository.  It may be a garbage, or some kind of
          # hidden stuff of the repository, ... etc.
          nil
        end
      }.compact
    end

    ##
    # The upper limit of files to search at one time.  The value has
    # no reason to select.  It seems to me that not too much, not too
    # little to handle in one process to search.

    LIMIT_OF_FILES = 20

    ##
    # When no timestamp pattern was given, invoke the searcher with
    # the repository root path as its argument and the recursive
    # searching option.  The search could be done in only one process.

    def invoke_searcher_at_repo_root(searcher, pattern)
      o, s = Open3.capture2(searcher, *find_searcher_options(searcher),
                            pattern, @path)
      output = []
      output += o.lines.map(&:chomp) if s.success? && (! o.empty?)
      output
    end

    ##
    # When a timestamp pattern was given, at first, list target files,
    # then invoke the searcher for those files.  Since the number of
    # target files may be so much, it seems to be dangerous to pass
    # all of them to a single search process at one time.
    #
    # One more thing to mention, the searcher, like `grep`, does not
    # add the filename at the beginning of the search result line, if
    # the target is one file.  This behavior is not suitable in this
    # purpose.  The code below adds the filename when the target is
    # one file.

    def invoke_searcher_for_entries(searcher, pattern, entries)
      output = []

      num_of_entries = entries.size
      if num_of_entries == 1
        # If the search taget is one file, the output needs special
        # treatment.
        file = abspath(entries[0])
        o, s = Open3.capture2(searcher, *find_searcher_options(searcher),
                              pattern, file)
        if s.success? && (! o.empty)
          output += o.lines.map { |line|
            # add filename at the beginning of the search result line
            [file, line.chomp].join(":")
          }
        end
      elsif num_of_entries > LIMIT_OF_FILES
        output += invoke_searcher_for_entries(searcher, pattern, entries[0..(LIMIT_OF_FILES - 1)])
        output += invoke_searcher_for_entries(searcher, pattern, entries[LIMIT_OF_FILES..-1])
      else
        # When the number of target is less than the upper limit,
        # invoke the searcher with all of target files as its
        # arguments.
        files = find_files(entries)
        o, s = Open3.capture2(searcher, *find_searcher_options(searcher),
                              pattern, *files)
        if s.success? && (! o.empty)
          output += o.lines.map(&:chomp)
        end
      end

      output
    end

    SEARCHER_OPTS = {
      # case insensitive, print line number, recursive search, work as egrep
      "grep"   => ["-i", "-n", "-R", "-E"],
      # case insensitive, print line number, recursive search
      "egrep"  => ["-i", "-n", "-R"],
      # case insensitive, print line number, recursive search, work as gegrep
      "ggrep"  => ["-i", "-n", "-R", "-E"],
      # case insensitive, print line number, recursive search
      "gegrep" => ["-i", "-n", "-R"],
      # smart case, print line number, no color
      "rg"     => ["-S", "-n", "--no-heading", "--color", "never"],
    }

    def find_searcher_options(searcher)
      @searcher_options || SEARCHER_OPTS[File.basename(searcher)] || ""
    end

    def find_files(timestamps)
      timestamps.map{|stamp| abspath(stamp)}
    end

    ##
    # The argument must be an Array contains the searcher output.
    # Each item is constructed from 3 parts:
    #   "<pathname>:<integer>:<text>"
    #
    # For example, it may looks like:
    #
    #   "/somewhere/2020/11/20201101044300.md:18:foo is foo"
    #
    # Or it may contains more ":" in the text part as:
    #
    #   "/somewhere/2020/11/20201101044500.md:119:apple:orange:grape"
    #
    # In the latter case, `split(":")` will split it too much.  That is,
    # the result will be:
    #
    #  ["/somewhere/2020/11/20201101044500.md", "119", "apple", "orange", "grape"]
    #
    # Text part must be joined with ":".

    def construct_search_result(output)
      output.map { |line|
        begin
          pathname, num, *match_text = line.split(":")
          [Timestamp.parse_s(timestamp_str(pathname)),
           num.to_i,
           match_text.join(":")]
        rescue InvalidTimestampStringError, TypeError => _
          raise InvalidSearchResultError, [@searcher, @searcher_options.join(" ")].join(" ")
        end
      }.compact
    end

    def find_searcher(program = nil)
      candidates = [FAVORITE_SEARCHER]
      candidates.unshift(program) unless program.nil? || candidates.include?(program)
      search_paths = ENV["PATH"].split(":")
      candidates.map { |prog|
        find_in_paths(prog, search_paths)
      }[0]
    end

    def find_in_paths(prog, paths)
      paths.each { |p|
        abspath = File.expand_path(prog, p)
        return abspath if FileTest.exist?(abspath) && FileTest.executable?(abspath)
      }
      nil
    end
    # :startdoc:

  end
end
