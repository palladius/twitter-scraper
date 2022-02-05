require "application_system_test_case"

class TwitterUsersTest < ApplicationSystemTestCase
  setup do
    @twitter_user = twitter_users(:one)
  end

  test "visiting the index" do
    visit twitter_users_url
    assert_selector "h1", text: "Twitter users"
  end

  test "should create twitter user" do
    visit twitter_users_url
    click_on "New twitter user"

    fill_in "Location", with: @twitter_user.location
    fill_in "Name", with: @twitter_user.name
    fill_in "Twitter", with: @twitter_user.twitter_id
    click_on "Create Twitter user"

    assert_text "Twitter user was successfully created"
    click_on "Back"
  end

  test "should update Twitter user" do
    visit twitter_user_url(@twitter_user)
    click_on "Edit this twitter user", match: :first

    fill_in "Location", with: @twitter_user.location
    fill_in "Name", with: @twitter_user.name
    fill_in "Twitter", with: @twitter_user.twitter_id
    click_on "Update Twitter user"

    assert_text "Twitter user was successfully updated"
    click_on "Back"
  end

  test "should destroy Twitter user" do
    visit twitter_user_url(@twitter_user)
    click_on "Destroy this twitter user", match: :first

    assert_text "Twitter user was successfully destroyed"
  end
end
