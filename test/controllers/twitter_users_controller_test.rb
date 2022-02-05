require "test_helper"

class TwitterUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @twitter_user = twitter_users(:one)
  end

  test "should get index" do
    get twitter_users_url
    assert_response :success
  end

  test "should get new" do
    get new_twitter_user_url
    assert_response :success
  end

  test "should create twitter_user" do
    assert_difference("TwitterUser.count") do
      post twitter_users_url, params: { twitter_user: { location: @twitter_user.location, name: @twitter_user.name, twitter_id: @twitter_user.twitter_id } }
    end

    assert_redirected_to twitter_user_url(TwitterUser.last)
  end

  test "should show twitter_user" do
    get twitter_user_url(@twitter_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_twitter_user_url(@twitter_user)
    assert_response :success
  end

  test "should update twitter_user" do
    patch twitter_user_url(@twitter_user), params: { twitter_user: { location: @twitter_user.location, name: @twitter_user.name, twitter_id: @twitter_user.twitter_id } }
    assert_redirected_to twitter_user_url(@twitter_user)
  end

  test "should destroy twitter_user" do
    assert_difference("TwitterUser.count", -1) do
      delete twitter_user_url(@twitter_user)
    end

    assert_redirected_to twitter_users_url
  end
end
