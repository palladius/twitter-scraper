require "test_helper"

class WordleGamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wordle_game = wordle_games(:one)
  end

  test "should get index" do
    get wordle_games_url
    assert_response :success
  end

  test "should get new" do
    get new_wordle_game_url
    assert_response :success
  end

  test "should create wordle_game" do
    assert_difference("WordleGame.count") do
      post wordle_games_url, params: { wordle_game: { cache_average_score: @wordle_game.cache_average_score, cache_tweets_count: @wordle_game.cache_tweets_count, date: @wordle_game.date, import_notes: @wordle_game.import_notes, import_version: @wordle_game.import_version, json_stuff: @wordle_game.json_stuff, notes: @wordle_game.notes, solution: @wordle_game.solution, wordle_incremental_day: @wordle_game.wordle_incremental_day, wordle_type: @wordle_game.wordle_type } }
    end

    assert_redirected_to wordle_game_url(WordleGame.last)
  end

  test "should show wordle_game" do
    get wordle_game_url(@wordle_game)
    assert_response :success
  end

  test "should get edit" do
    get edit_wordle_game_url(@wordle_game)
    assert_response :success
  end

  test "should update wordle_game" do
    patch wordle_game_url(@wordle_game), params: { wordle_game: { cache_average_score: @wordle_game.cache_average_score, cache_tweets_count: @wordle_game.cache_tweets_count, date: @wordle_game.date, import_notes: @wordle_game.import_notes, import_version: @wordle_game.import_version, json_stuff: @wordle_game.json_stuff, notes: @wordle_game.notes, solution: @wordle_game.solution, wordle_incremental_day: @wordle_game.wordle_incremental_day, wordle_type: @wordle_game.wordle_type } }
    assert_redirected_to wordle_game_url(@wordle_game)
  end

  test "should destroy wordle_game" do
    assert_difference("WordleGame.count", -1) do
      delete wordle_game_url(@wordle_game)
    end

    assert_redirected_to wordle_games_url
  end
end
