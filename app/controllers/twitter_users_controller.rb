class TwitterUsersController < ApplicationController
  before_action :set_twitter_user, only: %i[ show edit update destroy ]

  # GET /twitter_users or /twitter_users.json
  def index
    #@twitter_users = #TwitterUser.all.limit(150).sort()
    # getting top users
    sql_query_limit  = (params.fetch :sql_limit, 500).to_i
    n_days_freshness = (params.fetch :days, 3).to_i

    now = Time.now
    @twitter_users = TwitterUser.where(updated_at: (now - n_days_freshness * 24.hours)..now).left_joins(:tweets).group(:id).order('COUNT(tweets.id) DESC').limit(sql_query_limit)
    @top_polyglots = @twitter_users.map{|u| [u.twitter_id, u.polyglotism, u]}.sort{|a,b| a[1] <=> b[1] }.reverse.first(50)
  end

  # GET /twitter_users/1 or /twitter_users/1.json
  def show
  end

  # GET /twitter_users/new
  def new
    @twitter_user = TwitterUser.new
  end

  # GET /twitter_users/1/edit
  def edit
  end

  # POST /twitter_users or /twitter_users.json
  def create
    @twitter_user = TwitterUser.new(twitter_user_params)

    respond_to do |format|
      if @twitter_user.save
        format.html { redirect_to twitter_user_url(@twitter_user), notice: "Twitter user was successfully created." }
        format.json { render :show, status: :created, location: @twitter_user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @twitter_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /twitter_users/1 or /twitter_users/1.json
  def update
    respond_to do |format|
      if @twitter_user.update(twitter_user_params)
        format.html { redirect_to twitter_user_url(@twitter_user), notice: "Twitter user was successfully updated." }
        format.json { render :show, status: :ok, location: @twitter_user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @twitter_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_users/1 or /twitter_users/1.json
  def destroy
    @twitter_user.destroy

    respond_to do |format|
      format.html { redirect_to twitter_users_url, notice: "Twitter user was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twitter_user
      @twitter_user = TwitterUser.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def twitter_user_params
      params.require(:twitter_user).permit(:twitter_id, :name, :location)
    end
end
