require 'fileutils'
require 'test_helper'

class TextrepoFileSystemRepositorySearchTest < Minitest::Test
  def test_it_can_search_word
    assert_search("apple", 1, CONF_RO)
  end

  def test_it_can_search_regex_pattern
    assert_search("[Aa]p+le", 1, CONF_RO)
  end

  # [issue #38] #1
  def test_it_can_search_word_in_specified_entries
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    result = repo.search("ruby", "202001")
    assert_operator 2, :<=, result.size

    result = repo.search("swift", "20200101010003")
    assert_operator 1, :<=, result.size

    result = repo.search("^\\-\\ i", "20200101010000")
    assert_operator 7, :<=, result.size
  end

  def test_it_fails_with_inappropriate_options
    conf = CONF_RO.dup
    conf[:searcher] = "grep"
    conf[:searcher_options] = ["-i", "-R", "-A", "2", "-B", "2"]
    repo = Textrepo::FileSystemRepository.new(conf)
    assert_raises(Textrepo::InvalidSearchResultError) {
      repo.search("apple")
    }
  end
end
