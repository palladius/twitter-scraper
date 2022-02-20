class TweetsController < ApplicationController
  before_action :set_tweet, only: %i[ show edit update destroy regenerate ]
  # https://stackoverflow.com/questions/43180720/rails-error-pages-controller-and-redirecting-the-user
  rescue_from ActiveRecord::RecordNotFound, with: :salvataggio

  # GET /tweets or /tweets.json
  def index
    # 3 is latest ATM TODO(ricc): autopick the latest :)
    @tweets = Tweet.all.where(:import_version => "3" ).limit(8)
  end

  # GET /tweets/1 or /tweets/1.json
  def show
  end

  # GET /tweets/new
  def new
    @tweet = Tweet.new
  end

  # GET /tweets/:id/regenerate
  def regenerate

  end

  # GET /tweets/1/edit
  def edit
  end

  # POST /tweets or /tweets.json
  def create
    @tweet = Tweet.new(tweet_params)

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to tweet_url(@tweet), notice: "Tweet was successfully created." }
        format.json { render :show, status: :created, location: @tweet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tweets/1 or /tweets/1.json
  def update
    respond_to do |format|
      if @tweet.update(tweet_params)
        format.html { redirect_to tweet_url(@tweet), notice: "Tweet was successfully updated." }
        format.json { render :show, status: :ok, location: @tweet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweets/1 or /tweets/1.json
  def destroy
    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to tweets_url, notice: "Tweet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def salvataggio
    flash[:error] = "Some error in TweetsController"
    flash[:warn] = "Some WARN in TweetsController"
#    redirect_to "/tweets"
    redirect_to action: 'index'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id]) rescue redirect_to("root")
    end

    # Only allow a list of trusted parameters through.
    def tweet_params
      params.require(:tweet).permit(:twitter_user_id, :full_text)
    end
end
