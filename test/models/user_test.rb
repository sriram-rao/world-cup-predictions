require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes username" do
    user = User.new(username: " PLAYER_ONE ")
    assert_equal "player_one", user.username
  end
end
