require "test_helper"

class TextrepoRepositoryTest < Minitest::Test
  def test_it_has_init_method_to_get_concrete_repository_instance
    repo = Textrepo.init(CONF_RO)
    assert repo
  end

  def test_it_fails_when_unknown_type_was_specified_as_repository_type
    conf = CONF_RO.clone
    conf[:repository_type] = :foo_bar
    assert_raises(Textrepo::UnknownRepoTypeError) {
      Textrepo.init(conf)
    }
  end
end
