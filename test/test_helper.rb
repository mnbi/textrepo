$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "textrepo"

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
