require 'test_helper'

# [issue #47]
class TextrepoFileSystemRepositoryEntriesMmddTest < Minitest::Test
  def setup
    @conf_rw = CONF_RW.dup
    @conf_rw[:repository_name] = "test_repo_entries_mmdd"

    ["2020-11-16 00:00:00", "2020-09-10 11:16:00", "2020-10-11 12:11:16"].each { |t|
      filename = File.expand_path("#{t.tr('- :', '')}.md", repo_path(@conf_rw))
      write_text(filename, "text")
    }
  end

  def test_it_distinguish_mmdd_pattern_correctly
    repo = Textrepo::FileSystemRepository.new(@conf_rw)
    result = repo.entries("1116")

    assert_equal 1, result.size
    assert_equal "2020-11-16 00:00:00".tr("- :", ""), result[0].to_s
  end
end
