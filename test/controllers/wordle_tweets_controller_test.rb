require "test_helper"

class WordleTweetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wordle_tweet = wordle_tweets(:one)
  end

  test "should get index" do
    get wordle_tweets_url
    assert_response :success
  end

  test "should get new" do
    get new_wordle_tweet_url
    assert_response :success
  end

  test "should create wordle_tweet" do
    assert_difference("WordleTweet.count") do
      post wordle_tweets_url, params: { wordle_tweet: { score: @wordle_tweet.score, tweet_id: @wordle_tweet.tweet_id, wordle_date: @wordle_tweet.wordle_date, wordle_incremental_day: @wordle_tweet.wordle_incremental_day, wordle_type: @wordle_tweet.wordle_type } }
    end

    assert_redirected_to wordle_tweet_url(WordleTweet.last)
  end

  test "should show wordle_tweet" do
    get wordle_tweet_url(@wordle_tweet)
    assert_response :success
  end

  test "should get edit" do
    get edit_wordle_tweet_url(@wordle_tweet)
    assert_response :success
  end

  test "should update wordle_tweet" do
    patch wordle_tweet_url(@wordle_tweet), params: { wordle_tweet: { score: @wordle_tweet.score, tweet_id: @wordle_tweet.tweet_id, wordle_date: @wordle_tweet.wordle_date, wordle_incremental_day: @wordle_tweet.wordle_incremental_day, wordle_type: @wordle_tweet.wordle_type } }
    assert_redirected_to wordle_tweet_url(@wordle_tweet)
  end

  test "should destroy wordle_tweet" do
    assert_difference("WordleTweet.count", -1) do
      delete wordle_tweet_url(@wordle_tweet)
    end

    assert_redirected_to wordle_tweets_url
  end
end
