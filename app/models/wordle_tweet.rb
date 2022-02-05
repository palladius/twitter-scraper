class WordleTweet < ApplicationRecord
  belongs_to :tweet

  def to_s 
    "TODO 🌻 WordleTweet "
  end

  def tweet_text 
    self.tweet.full_text
  end

  def calculate_wordle_type 
    extended_wordle_match_type(tweet_text) # self.tweet.full_text)
  end 
    
  def extended_wordle_match_type(text, include_very_generic = true, exclude_wordle_english_for_debug=false)
      # returns TWO things: matches and id of
      return :wordle_en  if text.match?(/Wordle \d+ \d\/6/i) unless exclude_wordle_english_for_debug
      return :wordle_fr  if text.match?(/Le Mot \(@WordleFR\) \#\d+ .\/6/i)
      # "joguei http://term.ooo #34 X/6 *"
      return :wordle_pt  if text.match?(/joguei http:\/\/term.ooo \#34 .\/6/i )
      # I cant remember wha website was this.
      return :wordle_de2  if text.match?(/I guessed this German 5-letter word in .\/6 tries/)
      # This is better
      return :wordle_de  if text.match?(/http:\/\/wordle-spielen.de.*WORDLE.*\d+ .\/6/)
      return :lewdle     if text.match?(/Lewdle \d+ .\/6/) 
      
      # ParFlag of Italyle 369 3/6
      return :wordle_it  if text.match?(/Par.le \d+ .\/6/)
      return :nerdlegame if text.match?(/nerdlegame \d+ .\/6/i)
      
      return :wordle_ko  if text.match?(/#Korean #Wordle .* \d+ .\/6/)
  
      # Generic wordle - might want to remove in the future
      if include_very_generic
        return :other if text.match?(/ordle \d+ [123456X]\/6/i) unless exclude_wordle_english_for_debug
      end
      return nil
    end
  def parse_score_from_text
    m = tweet_text.match(/.\/6/)
    # first char of first match,  m[0] => "5/6"
    m[0][0] rescue nil
  end

  def parse_incrementalday_from_text
    #tweet_text = "Wordle 231 3/6"
    m = tweet_text.match(/Wordle (\d+) .\/6/)
    puts "[parse_incrementalday_from_text] Wordle integer is #{m[1] rescue $!}"
    m[1] rescue nil
  end

  define_singleton_method :create_from_tweet do |tweet|
    #puts "TODO(ricc): WordleTweet add new WordleTweet() based on tweet: #{tweet}"
    wt = WordleTweet.new 
    wt.tweet = tweet 
    wt.import_notes = "Not sure yet I should be doing it this way.."
    wt.wordle_type = wt.calculate_wordle_type
    wt.score = wt.parse_score_from_text()
    # TODO infer with some way, eg Wordle date for 232 is 5feb22.
    # wordle_date: date
    wt.wordle_incremental_day =  wt.parse_incrementalday_from_text() 
    # import_version: integer
    wt.import_version = 1 # First version
    # import_notes: text
  end
end 
# (Irina, Wurundjeri Land ☀️🌧❄️🍂🚃
