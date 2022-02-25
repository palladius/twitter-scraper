class WordleGamesController < ApplicationController
  before_action :set_wordle_game, only: %i[ show edit update destroy ]
  before_action :create_wg_if_doesnt_exist, only: %i[ index ]

  # GET /wordle_games or /wordle_games.json
  def index
    @max_games = params.fetch :limit, 5
    @wordle_games = WordleGame.all.limit(@max_games)
  end

  # GET /wordle_games/1 or /wordle_games/1.json
  def show
  end

  # GET /wordle_games/new
  def new
    @wordle_game = WordleGame.new
  end

  # GET /wordle_games/1/edit
  def edit
  end

  # POST /wordle_games or /wordle_games.json
  def create
    @wordle_game = WordleGame.new(wordle_game_params)

    respond_to do |format|
      if @wordle_game.save
        format.html { redirect_to wordle_game_url(@wordle_game), notice: "Wordle game was successfully created." }
        format.json { render :show, status: :created, location: @wordle_game }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @wordle_game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wordle_games/1 or /wordle_games/1.json
  def update
    respond_to do |format|
      if @wordle_game.update(wordle_game_params)
        format.html { redirect_to wordle_game_url(@wordle_game), notice: "Wordle game was successfully updated." }
        format.json { render :show, status: :ok, location: @wordle_game }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @wordle_game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wordle_games/1 or /wordle_games/1.json
  def destroy
    @wordle_game.destroy

    respond_to do |format|
      format.html { redirect_to wordle_games_url, notice: "Wordle game was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wordle_game
      @wordle_game = WordleGame.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def wordle_game_params
      params.require(:wordle_game).permit(:wordle_incremental_day, :wordle_type, :solution, :date, :json_stuff, :notes, :cache_average_score, :cache_tweets_count, :import_version, :import_notes)
    end

    def create_wg_if_doesnt_exist
      puts "[RICC] debug "
      if params[:find_or_create_by_wt_and_wid] == 'true'
        puts "[RICC] find_or_create_by_wt_and_wid ACTIVATED!"
        # todo mi sa che mi socta meno fare il create_or_detect nella view che ce n;'e; uno solo e costa meno...
        
      end
          #     <%= link_to  wt.game, "/wordle_games?&wordle_type=find_or_create_by_wt_and_wid=true&#{wt.wordle_type}&wordle_incremental_day=#{wt.wordle_incremental_day}"  %>
    # if exists -> reditrect to /wordle_games/:id
    # if it doesnt exist, either create and refitrect there OR redirect to NEW
    end
end
