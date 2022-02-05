class WordleTweetsController < ApplicationController
  before_action :set_wordle_tweet, only: %i[ show edit update destroy ]

  # GET /wordle_tweets or /wordle_tweets.json
  def index
    @wordle_tweets = WordleTweet.all
  end

  # GET /wordle_tweets/1 or /wordle_tweets/1.json
  def show
  end

  # GET /wordle_tweets/new
  def new
    @wordle_tweet = WordleTweet.new
  end

  # GET /wordle_tweets/1/edit
  def edit
  end

  # POST /wordle_tweets or /wordle_tweets.json
  def create
    @wordle_tweet = WordleTweet.new(wordle_tweet_params)

    respond_to do |format|
      if @wordle_tweet.save
        format.html { redirect_to wordle_tweet_url(@wordle_tweet), notice: "Wordle tweet was successfully created." }
        format.json { render :show, status: :created, location: @wordle_tweet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @wordle_tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wordle_tweets/1 or /wordle_tweets/1.json
  def update
    respond_to do |format|
      if @wordle_tweet.update(wordle_tweet_params)
        format.html { redirect_to wordle_tweet_url(@wordle_tweet), notice: "Wordle tweet was successfully updated." }
        format.json { render :show, status: :ok, location: @wordle_tweet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @wordle_tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wordle_tweets/1 or /wordle_tweets/1.json
  def destroy
    @wordle_tweet.destroy

    respond_to do |format|
      format.html { redirect_to wordle_tweets_url, notice: "Wordle tweet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wordle_tweet
      @wordle_tweet = WordleTweet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def wordle_tweet_params
      params.require(:wordle_tweet).permit(:wordle_type, :tweet_id, :score, :wordle_date, :wordle_incremental_day, :import_version, :import_notes)
    end
end
