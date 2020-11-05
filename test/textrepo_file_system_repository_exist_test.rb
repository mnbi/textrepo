require 'fileutils'
require 'test_helper'

class TextrepoFileSystemRepositoryEixstTest < Minitest::Test
  def test_it_returns_true_given_stamp_is_exists
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    assert repo.exist?(stamp)
  end

  def test_it_returns_false_given_stamp_is_missing
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    stamp = Textrepo::Timestamp.new(Time.new(1900, 1, 1, 1, 1, 1))
    refute repo.exist?(stamp)
  end
end
