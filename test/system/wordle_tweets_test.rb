require "application_system_test_case"

class WordleTweetsTest < ApplicationSystemTestCase
  setup do
    @wordle_tweet = wordle_tweets(:one)
  end

  test "visiting the index" do
    visit wordle_tweets_url
    assert_selector "h1", text: "Wordle tweets"
  end

  test "should create wordle tweet" do
    visit wordle_tweets_url
    click_on "New wordle tweet"

    fill_in "Import notes", with: @wordle_tweet.import_notes
    fill_in "Import version", with: @wordle_tweet.import_version
    fill_in "Score", with: @wordle_tweet.score
    fill_in "Tweet", with: @wordle_tweet.tweet_id
    fill_in "Wordle date", with: @wordle_tweet.wordle_date
    fill_in "Wordle incremental day", with: @wordle_tweet.wordle_incremental_day
    fill_in "Wordle type", with: @wordle_tweet.wordle_type
    click_on "Create Wordle tweet"

    assert_text "Wordle tweet was successfully created"
    click_on "Back"
  end

  test "should update Wordle tweet" do
    visit wordle_tweet_url(@wordle_tweet)
    click_on "Edit this wordle tweet", match: :first

    fill_in "Import notes", with: @wordle_tweet.import_notes
    fill_in "Import version", with: @wordle_tweet.import_version
    fill_in "Score", with: @wordle_tweet.score
    fill_in "Tweet", with: @wordle_tweet.tweet_id
    fill_in "Wordle date", with: @wordle_tweet.wordle_date
    fill_in "Wordle incremental day", with: @wordle_tweet.wordle_incremental_day
    fill_in "Wordle type", with: @wordle_tweet.wordle_type
    click_on "Update Wordle tweet"

    assert_text "Wordle tweet was successfully updated"
    click_on "Back"
  end

  test "should destroy Wordle tweet" do
    visit wordle_tweet_url(@wordle_tweet)
    click_on "Destroy this wordle tweet", match: :first

    assert_text "Wordle tweet was successfully destroyed"
  end
end
