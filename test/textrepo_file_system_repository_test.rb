require 'fileutils'
require 'test_helper'

class TextrepoFileSystemRepositoryTest < Minitest::Test
  def test_it_can_be_instantiated_with_valid_conf
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    assert repo
  end

  # for accessor
  def test_it_has_appropriate_type
    expected = :file_system
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    assert_equal expected, repo.type
  end

  def test_it_has_default_name_value
    expected = 'notes'
    conf = CONF_RW.clone
    conf.delete(:repository_name)
    repo = Textrepo::FileSystemRepository.new(conf)
    assert_equal expected, repo.name
  end

  def test_it_has_accessor_for_path_attribute
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    expected = File.expand_path(CONF_RO[:repository_name], CONF_RO[:repository_base])
    assert_equal expected, repo.path
  end

  def test_it_has_accessor_for_extname_attribute
    expected = "txt"
    conf = CONF_RO.clone
    conf[:default_extname] = expected
    repo = Textrepo::FileSystemRepository.new(conf)
    assert_equal expected, repo.extname
  end
end
