module Textrepo
  class Timestamp
    include Comparable

    attr_reader :time, :suffix

    # time: a Time instance
    # suffix: an Integer instance
    def initialize(time, suffix = nil)
      @time = time
      @suffix = suffix
    end

    def <=>(other)
      result = (self.time <=> other.time)

      sfx = self.suffix || 0
      osfx = other.suffix || 0

      result == 0 ? (sfx <=> osfx) : result
    end

    #  %Y   %m %d %H %M %S  suffix
    # "2020-12-30 12:34:56  (0 | nil)" => "20201230123456"
    # "2020-12-30 12:34:56  (7)"       => "20201230123456_007"
    def to_s
      s = @time.strftime("%Y%m%d%H%M%S")
      s += "_#{"%03u" % @suffix}" unless @suffix.nil? || @suffix == 0
      s
    end

    #  %Y   %m %d %H %M %S  suffix        %Y/%m/  %Y%m%d%H%M%S %L
    # "2020-12-30 12:34:56  (0 | nil)" => "2020/12/20201230123456"
    # "2020-12-30 12:34:56  (7)"       => "2020/12/20201230123456_007"
    def to_pathname
      @time.strftime("%Y/%m/") + self.to_s
    end

    class << self
      #  yyyymoddhhmiss sfx      yyyy    mo    dd    hh    mi    ss    sfx
      # "20201230123456"     => "2020", "12", "30", "12", "34", "56"
      # "20201230123456_789" => "2020", "12", "30", "12", "34", "56", "789"
      def split_stamp(stamp_str)
        #    yyyy  mo    dd    hh    mi      ss      sfx
        a = [0..3, 4..5, 6..7, 8..9, 10..11, 12..13, 15..17].map {|r| stamp_str[r]}
        a[-1].nil? ? a[0..-2] : a
      end

      def parse_s(stamp_str)
        year, mon, day, hour, min, sec , sfx = split_stamp(stamp_str).map(&:to_i)
        Timestamp.new(Time.new(year, mon, day, hour, min, sec), sfx)
      end

      #                      (-2)
      #  0       8           |(-1)
      #  V       V           VV
      # "2020/12/20201230123456" => "2020-12-30 12:34:56"
      def parse_pathname(pathname)
        parse_s(pathname[8..-1])
      end
    end
  end
end
