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
  end

  def wordle
  end
end
