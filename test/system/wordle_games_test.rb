require "application_system_test_case"

class WordleGamesTest < ApplicationSystemTestCase
  setup do
    @wordle_game = wordle_games(:one)
  end

  test "visiting the index" do
    visit wordle_games_url
    assert_selector "h1", text: "Wordle games"
  end

  test "should create wordle game" do
    visit wordle_games_url
    click_on "New wordle game"

    fill_in "Cache average score", with: @wordle_game.cache_average_score
    fill_in "Cache tweets count", with: @wordle_game.cache_tweets_count
    fill_in "Date", with: @wordle_game.date
    fill_in "Import notes", with: @wordle_game.import_notes
    fill_in "Import version", with: @wordle_game.import_version
    fill_in "Json stuff", with: @wordle_game.json_stuff
    fill_in "Notes", with: @wordle_game.notes
    fill_in "Solution", with: @wordle_game.solution
    fill_in "Wordle incremental day", with: @wordle_game.wordle_incremental_day
    fill_in "Wordle type", with: @wordle_game.wordle_type
    click_on "Create Wordle game"

    assert_text "Wordle game was successfully created"
    click_on "Back"
  end

  test "should update Wordle game" do
    visit wordle_game_url(@wordle_game)
    click_on "Edit this wordle game", match: :first

    fill_in "Cache average score", with: @wordle_game.cache_average_score
    fill_in "Cache tweets count", with: @wordle_game.cache_tweets_count
    fill_in "Date", with: @wordle_game.date
    fill_in "Import notes", with: @wordle_game.import_notes
    fill_in "Import version", with: @wordle_game.import_version
    fill_in "Json stuff", with: @wordle_game.json_stuff
    fill_in "Notes", with: @wordle_game.notes
    fill_in "Solution", with: @wordle_game.solution
    fill_in "Wordle incremental day", with: @wordle_game.wordle_incremental_day
    fill_in "Wordle type", with: @wordle_game.wordle_type
    click_on "Update Wordle game"

    assert_text "Wordle game was successfully updated"
    click_on "Back"
  end

  test "should destroy Wordle game" do
    visit wordle_game_url(@wordle_game)
    click_on "Destroy this wordle game", match: :first

    assert_text "Wordle game was successfully destroyed"
  end
end
