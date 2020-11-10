require "forwardable"

module Textrepo
  ##
  # Timestamp is generated from a Time object.  It converts a time to
  # string in the obvious format, such "20201023122400".
  #
  # Since the obvious format contains only year, month, day, hour,
  # minute, and second, the resolution of time is a second.  That is,
  # two Time object those are different only in second will generates
  # equal Timestamp objects.
  #
  # If a client program of Textrepo::Timestamp wants to distinguish
  # those Time objects, an attribute `suffix` could be used.
  #
  # For example, the `suffix` will be converted into a 3 character
  # string, such "012", "345", "678", ... etc.  So, millisecond part
  # of a Time object will be suitable to pass as `suffix` when
  # creating a Timestamp object.

  class Timestamp
    include Comparable
    extend Forwardable

    ##
    # Time object which generates the Timestamp object.

    attr_reader :time

    ##
    # An integer specified in `new` method to create the Timestamp object.

    attr_reader :suffix

    ##
    # String object which is regarded as a value of Timestamp object.
    # The value is generated from @time and @suffix.

    attr_reader :str

    ##
    # Creates a Timestamp object from a Time object.  In addition, an
    # Integer can be passed as a suffix use.
    #
    # Since Textrepo adapts 1 second as the time resolution, the
    # subsec part of a given time will be ignored.
    #
    # :call-seq:
    #   new(Time, Integer = nil) -> Timestamp

    def initialize(time, suffix = nil)
      raise ArgumentRangeError, suffix unless is_valid_suffix?(suffix)
      parts = [:year, :mon, :day, :hour, :min, :sec].map{ |s| time.send(s) }
      @time = Time.new(*parts)
      @suffix = suffix
      @str = time_to_str(@time, @suffix)
    end

    def <=>(other)              # :nodoc:
      result = (self.time <=> other.time)

      sfx = self.suffix || 0
      osfx = other.suffix || 0

      result == 0 ? (sfx <=> osfx) : result
    end

    ##
    # Generates an obvious time string.
    #
    #    %Y   %m %d %H %M %S  suffix
    #   "2020-12-30 12:34:56  (0 | nil)" -> "20201230123456"
    #   "2020-12-30 12:34:56  (7)"       -> "20201230123456_007"

    def to_s
      @str
    end

    alias to_str to_s

    # :stopdoc:

    # delegators to Time object

    def_instance_delegators :@time, :year, :mon, :day, :hour, :min, :sec
    def_instance_delegators :@time, :wday, :monday?, :tuesday?, :wednesday?, :thursday?, :friday?, :saturday?, :sunday?
    def_instance_delegators :@time, :asctime, :ctime, :strftime
    def_instance_delegators :@time, :subsec, :nsec, :usec
    def_instance_delegators :@time, :tv_nsec, :tv_sec, :tv_usec
    def_instance_delegators :@time, :to_f, :to_i, :to_r
    def_instance_delegators :@time, :yday, :mday
    def_instance_delegators :@time, :month

    # :startdoc:

    def hash                    # :nodoc:
      @str[0, 14].to_i * 1000 + @suffix.to_i
    end

    def eql?(other)             # :nodoc:
      other.is_a?(Timestamp) && @time == other.time && @suffix == other.suffix
    end

    ##
    # Returns a new Timestamp object which is given seconds ahead.
    # Even if the suffix is not nil, the new Timestamp object will
    # always have nil as its suffix.
    #
    # :call-seq:
    #     +(Integer) -> Timestamp

    def +(seconds)
      Timestamp.new(@time + seconds, nil)
    end

    ##
    # Returns difference of seconds between self and an argument.  If
    # the argument is an Integer object, returns a new Timestamp
    # object which is the given seconds behind.
    #
    # Even if the suffix is not nil, the new Timestamp object will
    # always have nil as its suffix.
    #
    # :call-seq:
    #     -(Time) -> Float
    #     -(Timetamp) -> Float
    #     -(Integer) -> Timestamp

    def -(arg)
      case arg
      when Time
        @time - arg
      when Timestamp
        @time - arg.time
      when Integer
        Timestamp.new(@time - arg, nil)
      when NilClass
        raise TypeError, "can't convert nil into an exact number"
      else
        raise ArgumentError, arg
      end
    end

    ##
    # Generates an array contains components of the Timestamp object.
    # Components means "year", "mon", "day", "hour", "min", "sec", and
    # "suffix".

    def to_a
      a = [:year, :mon, :day, :hour, :min, :sec, :suffix].map { |s| self.send(s) }
      a.delete_at(-1) if a[-1].nil?
      a
    end

    # :stopdoc:

    # delegators to String object
    
    def_instance_delegators :@str, :size, :length
    def_instance_delegators :@str, :include?, :match, :match?

    # :startdoc:

    ##
    # Returns a character or sub-string specified with args.
    #
    # Following type of objects could be used as args:
    #
    # - Integer          : specifies an index
    # - Integer, Integer : specified an start index and length of sub-string
    # - Range            : specified range of sub-string
    # - Symbol           : specified a type of part
    #
    # Following symbols could be specified:
    #
    # - :year
    # - :mon, or :month
    # - :day
    # - :hour
    # - :min
    # - :sec
    # - :suffix
    #
    # :call-seq:
    #     self[nth as Integer] -> String | nil
    #     self[nth as Integer, len as Integer] -> String | nil
    #     self[range as Range] -> String
    #     self[symbol as Symbol] -> String

    def [](*args)
      raise ArgumentError, "wrong number of arguments (given %s, execpted 1..2)" % args.size unless (1..2).include?(args.size)

      arg = args[0]
      case arg
      when Symbol, String
        key = arg.to_sym
        if key == :suffix
          @suffix.nil? ? nil : FMTSTRS[key] % @suffix
        elsif FMTSTRS.keys.include?(key)
          @time.strftime(FMTSTRS[key])
        else
          nil
        end
      else
        @str[*args]
      end
    end

    alias slice []

    ##
    # Returns a Timestamp object which has a next Time object.
    #
    # If true was passed as an argument, use incremented suffix as
    # base instead of a next Time object.
    #
    # For example,
    #
    #     "20201110160100"     -> "20201110160101"     (false as arg)
    #     "20201110160100"     -> "20201110160100_001" (true as arg)
    #     "20201110160200_001" -> "20201110160201"     (false as arg)
    #     "20201110160200_001" -> "20201110160200_002" (true as arg)
    #
    # If suffix was 999 before call this method, raises
    # ArgumentRangeError.

    def next(use_suffix = nil)
      if use_suffix
        Timestamp.new(@time, increase_suffix(@suffix.to_i, 1))
      else
        Timestamp.new(@time + 1, nil)
      end
    end

    alias succ next

    ##
    # Updates the time value to a next Time destructively.  See the
    # document for Timestamp#next for more details.
    #
    # If suffix was 999 before call this method, raises
    # ArgumentRangeError.

    def next!(use_suffix = nil)
      if use_suffix
        @suffix = increase_suffix(@suffix.to_i, 1)
      else
        @time += 1
        @suffix = nil
      end
      @str = time_to_str(@time, @suffix)
      self
    end

    alias succ! next!

    ##
    # Splits the timestamp string into array of time parts, such as
    # year, month, day, hour, minute, and second.  Then, returns the
    # array.
    #
    # When a block was passed, it would apply to each part of the
    # array.  Then, returns self.

    def split(_ = $;, _ = 0, &blk)
      parts = Timestamp.split_stamp(@str)
      if blk.nil?
        parts
      else
        parts.each { |p| yield p }
        self
      end
    end

    # :stopdoc:

    def initialize_copy(_)
      @time = @time.dup
      @suffix = @suffix
      @str = @str.dup
    end

    def freeze;  @time.freeze;  @suffix.freeze;  @str.freeze;  end
    def taint;   @time.taint;   @suffix.taint;   @str.taint;   end
    def untaint; @time.untaint; @suffix.untaint; @str.untaint; end

    private

    def is_valid_suffix?(suffix)
      suffix.nil? || (0..999).include?(suffix)
    end

    def increase_suffix(suffix, num)
      increased = suffix + num
      raise ArgumentRangeError, suffix unless is_valid_suffix?(increased)
      increased
    end

    def time_to_str(time, suffix = nil)
      s = @time.strftime("%Y%m%d%H%M%S")
      s += "_#{"%03u" % @suffix}" unless @suffix.nil? || @suffix == 0
      s
    end

    FMTSTRS = {
      :year => "%Y", :mon => "%m", :month => "%m", :day => "%d",
      :hour => "%H", :min => "%M", :sec => "%S", :suffix => "%03u",
    }

    # :startdoc:
    class << self

      ##
      # Returns a Timestamp object generated from the current time.

      def now(suffix = nil)
        Timestamp.new(Time.now, suffix)
      end

      ##
      # Splits a string which represents a timestamp into components.
      # Each component represents a part of constructs to instantiate
      # a Time object.
      #
      #    yyyymoddhhmiss sfx      yyyy    mo    dd    hh    mi    ss    sfx
      #   "20201230123456"     -> "2020", "12", "30", "12", "34", "56"
      #   "20201230123456_789" -> "2020", "12", "30", "12", "34", "56", "789"
      #
      # Raises InvalidTimestampStringError if nil was passed as an arguemnt.

      def split_stamp(stamp_str)
        raise InvalidTimestampStringError, stamp_str if stamp_str.nil?
        #    yyyy  mo    dd    hh    mi      ss      sfx
        a = [0..3, 4..5, 6..7, 8..9, 10..11, 12..13, 15..17].map {|r| stamp_str[r]}
        a.delete_at(-1) if a[-1].nil?
        a
      end

      ##
      # Generate a Timestamp object from a string which represents a
      # timestamp, such "20201028163400".
      #
      # Raises InvalidTimestampStringError if cannot convert the
      # argument into a Timestamp object.
      #
      # :call-seq:
      #     parse_s("20201028163400") -> Timestamp
      #     parse_s("20201028163529_034") -> Timestamp

      def parse_s(stamp_str)
        begin
          ye, mo, da, ho, mi, se, sfx = split_stamp(stamp_str).map(&:to_i)
          Timestamp.new(Time.new(ye, mo, da, ho, mi, se), sfx)
        rescue InvalidTimestampStringError, ArgumentError => _
          emsg = if stamp_str.nil?
            "(nil)"
          elsif stamp_str.empty?
            "(empty string)"
          else
            stamp_str
          end
          raise InvalidTimestampStringError, emsg
        end
      end
    end

  end
end
