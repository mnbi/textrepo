require 'fileutils'

SAMPLE_TEXT_DIR = File.expand_path('text', __dir__)
repo_path = File.expand_path('test_repo', __dir__)
FileUtils.mkdir_p(repo_path)

files = Dir.entries(SAMPLE_TEXT_DIR).filter_map { |e|
  e = File.expand_path(e, SAMPLE_TEXT_DIR)
  e if FileTest.file?(e)
}

year, month, day, hour, min, sec = [2020, 1, 1, 1, 0, 0]

def min(x, y); x <= y ? x : y; end

stamps = []
1.upto(min(files.size, 60)) { |i|
  stamps << Time.new(year, month, day, hour, min, sec + (i - 1))
}

files.each { |abspath|
  t = stamps.shift
  yyyy = "%04d" % t.year
  mm   = "%02d" % t.month
  dd   = "%02d" % t.day
  hhmmss = "%02d%02d%02d" % [t.hour, t.min, t.sec]

  dirname = File.expand_path("#{yyyy}/#{mm}", repo_path)
  dest = "#{dirname}/#{yyyy}#{mm}#{dd}#{hhmmss}#{File.extname(abspath)}"

  FileUtils.mkdir_p(dirname)
  FileUtils.copy_file(abspath, dest) unless FileTest.exist?(dest) && FileUtils.cmp(abspath, dest)
}