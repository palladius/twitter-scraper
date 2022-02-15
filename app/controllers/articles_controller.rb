class ArticlesController < ApplicationController
  def index
  end

  def stats
  end

  def about
    # todo sort
    @last_tweets = Tweet.last(10)
  end

  def wordle
  end
end
