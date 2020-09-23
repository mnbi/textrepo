module Textrepo
  class Timestamp
    include Comparable

    def initialize(time)
      @time = time
    end

    def <=>(other)
      self.to_s <=> other.to_s
    end

    # "2020-12-30 12:34:56" => "20201230123456"
    def to_s
      @time.to_s[0, 19].gsub(/[- :]/, '')
    end

    #  yyyymoddhhmiss      yyyy mo
    # "20201230123456" => "2020/12/"20201230123456"
    def to_pathname
      yyyy, mo, dd, hh, mi, ss = Timestamp.split_stamp(self.to_s)
      "#{yyyy}/#{mo}/#{yyyy}#{mo}#{dd}#{hh}#{mi}#{ss}"
    end

    class << self
      #  yyyymoddhhmiss      yyyy    mo    dd    hh    mi    ss
      # "20201230123456" => "2020", "12", "30", "12", "34", "56"
      def split_stamp(stamp_str)
        [0..3, 4..5, 6..7, 8..9, 10..11, 12..13].map {|r| stamp_str[r]}
      end

      # "20201230123456" => "2020-12-30 12:34:56"
      def parse_s(stamp_str)
        year, mon, day, hour, min, sec = split_stamp(stamp_str).map(&:to_i)
        Timestamp.new(Time.new(year, mon, day, hour, min, sec))
      end

      # "2020/12/20201230123456" => "2020-12-30 12:34:56"
      def parse_pathname(pathname)
        parse_s(pathname[8..-1])
      end
    end
  end
end
