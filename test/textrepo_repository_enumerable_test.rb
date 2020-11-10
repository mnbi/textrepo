require "test_helper"

class TextrepoRepositoryEnumerableTest < Minitest::Test
  def setup
    @repo = Textrepo.init(CONF_RO)
  end

  def test_it_can_enumerate_with_each_key
    keys = []
    @repo.each_key { |timestamp| keys << timestamp }
    assert_equal @repo.entries.sort, keys.sort
  end

  def test_it_returns_enumerator_of_each_key
    enum = @repo.each_key
    assert_equal @repo.entries.sort, enum.entries.sort
  end

  def test_it_can_enumerate_with_each_value
    all_lines = []
    @repo.each_value { |text| all_lines.concat(text) }

    assert_equal read_all_lines(@repo).sort, all_lines.sort
  end

  def test_it_returns_enumerator_of_each_value
    enum = @repo.each_value
    assert_equal read_all_lines(@repo).sort, enum.entries.flatten.sort
  end

  def test_it_can_enumerate_with_each
    keys = []
    all_lines = []
    @repo.each { |timestamp, text|
      keys << timestamp
      all_lines.concat(text)
    }

    entries = @repo.entries

    assert_equal entries.sort, keys.sort
    assert_equal read_all_lines(@repo).sort, all_lines.sort
  end

  def test_it_returns_enumerator_of_each
    enum = @repo.each
    begin
      while true
        pair = enum.next
        assert_equal @repo.read(pair[0]), pair[1]
      end
    rescue StopIteration => _
    end
  end

  private
  def read_all_lines(repo)
    repo.entries.collect_concat { |stamp| repo.read(stamp) }
  end
end
