require 'test_helper'

class UserTest < ActiveSupport::TestCase

  should have_many(:comments).dependent(:nullify)
  should have_many(:contributions).dependent(:nullify)
  should validate_presence_of(:alias)
  should validate_uniqueness_of(:alias)

  test "should be valid" do
    assert users(:one).valid?
  end

  # TODO: faltan varios test de user

end
