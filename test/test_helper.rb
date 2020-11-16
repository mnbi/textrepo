$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "textrepo"

require 'fileutils'
require "minitest/autorun"

CONF_RO = {
  :repository_type => :file_system,
  :repository_name => "test_repo",
  :repository_base => File.expand_path("fixtures", __dir__)
}

CONF_RW = {
  :repository_type => :file_system,
  :repository_name => "test_repo",
  :repository_base => File.expand_path("sandbox", __dir__),
  :default_extname => 'md'
}

def setup_read_write_repo(conf_rw)
  # prepare a file into the sandobx repository
  stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
  stmp_sfx = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0), 88)

  repo_rw_path = repo_path(conf_rw)
  dst = File.expand_path(timestamp_to_pathname(stamp) + '.md', repo_rw_path)
  dst_sfx = File.expand_path(timestamp_to_pathname(stmp_sfx) + '.md',
                             repo_rw_path)

  repo_ro_path = repo_path(CONF_RO)
  src = File.expand_path(timestamp_to_pathname(stamp) + '.md', repo_ro_path)

  FileUtils.mkdir_p(File.dirname(dst))
  FileUtils.copy_file(src, dst)
  FileUtils.copy_file(src, dst_sfx)
end

def repo_path(conf)
  File.expand_path(conf[:repository_name], conf[:repository_base])
end

def write_text(path, text)
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, "w") { |f| f.write(text) }
end

def timestamp_to_pathname(timestamp)
  yyyy, mo = Textrepo::Timestamp.split_stamp(timestamp.to_s)[0..1]
  File.join(yyyy, mo, timestamp.to_s)
end

def assert_entries_pattern(pattern, num, conf)
  repo = Textrepo::FileSystemRepository.new(conf)
  entries = repo.entries(pattern)
  assert_equal num, entries.size
  assert entries.reduce(false) {|r, e| r ||= e.to_s.include?(pattern)}
end

def assert_search(pattern, num, conf)
  repo = Textrepo::FileSystemRepository.new(conf)
  result = repo.search(pattern)
  assert_operator num, :<=, result.size
end
