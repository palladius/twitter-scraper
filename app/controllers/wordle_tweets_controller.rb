class WordleTweetsController < ApplicationController
  before_action :set_wordle_tweet, only: %i[ show edit update destroy ]

  DEFAULT_LIMIT = 21 # 42 / 2 :) 
  # GET /wordle_tweets or /wordle_tweets.json
  def index
    
    @max_instances = params[:limit] { DEFAULT_LIMIT }
    # I feel this is CRAPPY code.. i just want to distinguish between NIL as an answer and NO presence of the param.
    wordle_type_or_nil = params[:wordle_type]{ :all}.to_s 
    # params[:wordle_type].nil? ? 'all' : params[:wordle_type].to_s
    @wordle_type = wordle_type_or_nil
    @graphs = []

    #https://stackoverflow.com/questions/31271620/how-to-filter-with-multiple-parameters-in-rails
    if params[:game].present? # This assumes that we have BOTH WT and WID
      if params[:game] == 'true'
        @wordle_tweets = WordleTweet.where(
            wordle_type:  params[:wordle_type],
            wordle_incremental_day: params[:wordle_incremental_day],
        )
        @spiegone = "ho game: assumo di avere sia WT(#{params[:wordle_type]}) and WID(#{ params[:wordle_incremental_day]}) :)"
        @graphs << "game"
      else
        @spiegone = "ho game ma non e TRUE: nonn so che cacchio fare e ritorno array vuoto."
        @wordle_tweets = [] 
      end
  
#      @posts = @posts.unit(params[:game]) 
      #@wordle_tweets = WordleTweet.all.limit(@max_instances)
      #@wordle_tweets = WordleTweet.where(wordle_type: 'wordle_it') # .order(created_at: :desc)
    elsif params[:wordle_type].present? # WT but not GAME, nota
#      @wordle_tweets = WordleTweet.all.limit(@max_instances)
      @wordle_tweets = WordleTweet.where(wordle_type: wordle_type_or_nil) # .limit(@max_instances)
      @spiegone = "ho wordle_type v2"
      @graphs << "wordle_type"
    else # no limits
      @wordle_tweets = WordleTweet.all.limit(@max_instances)
      @spiegone = "3) non cho una fava"
    end

    # @graphs contains array of graphs to do :)
    @wordle_tweets =  @wordle_tweets.limit(@max_instances).order(created_at: :desc)
    @grouped_tweets = WordleTweet.all.group(:wordle_type).count
    # if (wordle_type_or_nil.in? ["all", ""])
    #   # get all
    #   @wordle_tweets = WordleTweet.all.limit(@max_instances)
    # else
    #   # get only certain type
    #   @wordle_tweets = WordleTweet.where(wordle_type: wordle_type_or_nil).limit(@max_instances)
    # end
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
