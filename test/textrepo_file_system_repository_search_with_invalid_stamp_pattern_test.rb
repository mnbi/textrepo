require 'fileutils'
require 'test_helper'

class TextrepoFileSystemRepositorySearchWithsInvalidStampPatternTest < Minitest::Test
  # [issue #54]
  def test_it_returns_empty_array_when_passed_invalid_pattern
    conf = CONF_RW.dup
    conf[:repository_name] = "test_repo_entries_passed_invalid_pattern"
    conf[:searcher] = File.expand_path("fake_searcher", __dir__)
    conf[:searcher_options] = []

    repo = Textrepo::FileSystemRepository.new(conf)
    hoge_path = repo_path(conf) + "/hoge"
    FileUtils.mkdir_p(hoge_path)
    File.open(hoge_path + "/hogeboge.md", "w"){|f| f.puts("hoge")}

    invalid_pattern = "hogebo"
    entries = repo.search("hoge", invalid_pattern)

    assert_empty entries
  end
end
