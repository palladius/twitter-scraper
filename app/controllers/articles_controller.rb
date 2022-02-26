class ArticlesController < ApplicationController
  def index
  end

  def stats
  end

  def about
    # todo sort
#    @last_tweets = Tweet.last(10)
    @last_tweets = Tweet.last(10).reverse
    @last_users = TwitterUser.last(10).reverse
=begin
                                                                                                            
[[nil, 6465],                                                                                                      
 ["233", 2158],                                                                                                    
 ["234", 1298],                                                                                                    
 ["232", 757],                                                                                                     
 ["231", 445],                                                                                                     
 ["int/241", 339],                                                                                                 
 ["int/37", 299],                                                                                                  
 ["int/239", 287],                                                                                                 
 ["int/240", 270],                                                                                                 
 ["238", 151]]           

=end
    # WordleTweet.group(:wordle_incremental_day).count.sort_by {|k,v| v}.reverse.first(10)
   # @last_games = WordleTweet.group(:wordle_incremental_day).count.sort_by {|k,v| v}.reverse.select{|k,v| not k.nil? }.first(10)
    @last_games = WordleGame.all.first(10)
  end

  def dialects
    @wts_freshness = WordleTweet.group(:wordle_type).maximum(:created_at)
#    flash[:warn] = "prova 1 2 3"
  end

  def wordle
  end
end
