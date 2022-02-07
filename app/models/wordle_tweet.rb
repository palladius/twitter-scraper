class WordleTweet < ApplicationRecord
  belongs_to :tweet

  def to_s 
    #"TODO 🌻 WordleTweet "
    "WT#{WordleTweet.flag_by_type(wordle_type)}[#{wordle_type}] #{score}/6 (len=#{length})"
  end

  def tweet_text 
    self.tweet.full_text
  end

  def length
    self.tweet.length
  end

  def calculate_wordle_type 
    WordleTweet.extended_wordle_match_type(tweet_text) # self.tweet.full_text)
  end 
    
  def parse_score_from_text
    m = tweet_text.match(/.\/6/)
    # first char of first match,  m[0] => "5/6"
    m[0][0] rescue nil
  end

  # this parses and SAVES it/. So if you had a mistake you're writing it WRONG :/
  def parse_incrementalday_from_text
    #tweet_text = "Wordle 231 3/6"
    m = tweet_text.match(/ (\d+) .\/6/)
    puts "[parse_incrementalday_from_text] Issues matching day in '#{tweet_text}'" unless m
    #puts "[parse_incrementalday_from_text] Wordle integer is #{m[1] rescue $!}"
    m[1] rescue nil
  end

  def self.find_italian_orphans()
    # All by NIL :)

  end
  # I believe this shoiuld jhust be a bloody Class function :)
  #define_singleton_method :create_from_tweet do |tweet|
  def self.create_from_tweet(tweet)
    #puts "TODO(ricc): WordleTweet.create_from_tweet() based on tweet: #{tweet.excerpt}"
    wt = WordleTweet.new 
    wt.tweet = tweet 
    wt.import_notes = "Not sure yet I should be doing it this way.."
    wt.wordle_type = wt.calculate_wordle_type
    wt.score = wt.parse_score_from_text()
    # TODO infer with some way, eg Wordle date for 232 is 5feb22.
    # wordle_date: date
    wt.wordle_incremental_day =  wt.parse_incrementalday_from_text() 
    # import_version: integer
    wt.import_version = 2 # First version
    # CHANGELOG
    # v1 - Uswed to be the normal one
    # v2 2022-02-06 I've added created_at to Tweet based on ORIGINAL tweet.
    # import_notes: text
    save = wt.save
    puts "DEB save issues: #{save}" unless save
    save
  end



###### STATIC METHODS ###

  # returns TWO things: matches and id of
  # TODO(ricc): messo parole che parsa meglio ma poi dila non parsa bene non so perche..
  def self.extended_wordle_match_type(text, include_very_generic = true, 
    exclude_wordle_english_for_debug=false,
    include_only_italian_for_debug=false)

    ## ITALIAN START

    # ParFlag of Italyle 369 3/6
    # Par🇮🇹l matches  /Par..le/i 
    return :wordle_it  if text.match?(/Par..le \d+ .\/6.*/i)
    return :wordle_it  if text.match?(/Par🇮🇹le \d+ .\/6/i)

      # ParFlag of Italyle 369 3/6
      # PAR🇮🇹LE
      return :wordle_it1_ciofeco  if text.match?(/Par.+le \d+ .\/6/i)
      # Pietro version Par🇮🇹le 370 1/6 🟩🟩🟩🟩🟩
      # testiamo per poco il 1/2
      return :wordle_it2_ciofeco  if text.match?(/Par🇮🇹le \d+ .\/6/i)
      return :wordle_it3_removeme  if text.match?(/par.+le \d+ .\/6/i)

    ## ITALIAN END
    return nil if include_only_italian_for_debug 



    # returns TWO things: matches and id of
    return :wordle_fr  if text.match?(/Le Mot \(@WordleFR\) \#\d+ .\/6/i)
    # "joguei http://term.ooo #34 X/6 *"
    return :wordle_pt  if text.match?(/joguei http:\/\/term.ooo \#34 .\/6/i )
    # I cant remember wha website was this.
    return :wordle_de2  if text.match?(/I guessed this German 5-letter word in .\/6 tries/)
    # This is better
    return :wordle_de  if text.match?(/http:\/\/wordle-spielen.de.*WORDLE.*\d+ .\/6/)
    return :lewdle     if text.match?(/Lewdle \d+ .\/6/) 
    
    return :nerdlegame if text.match?(/nerdlegame \d+ .\/6/i)
    
    return :wordle_ko  if text.match?(/#Korean #Wordle .* \d+ .\/6/)

    return :wordle_en  if text.match?(/Wordle \d+ \d\/6/i) unless exclude_wordle_english_for_debug

    # Generic wordle - might want to remove in the future
    if include_very_generic
      return :other if text.match?(/ordle \d+ [123456X]\/6/i) unless exclude_wordle_english_for_debug
    end
    return nil
  end

  # This should be the only necessary thingy to CREATE a tweet. Them if the WT fails, i can do with next iterations
  def self.quick_match(txt)
    # ITA EN
    txt.match?(/(ordle|par..le) \d+ [123456X]\/6/i ) or 
      # FR: https://twitter.com/search?q=wordlefr&src=typed_query
      txt.match?(/WordleFR.*#\d+ [123456X]\/6/i) or 
      # BR OT: joguei https://t.co/TVFNN8ARo6 #36 2/6 *
      txt.match?(/joguei.*#\d+ [123456X]\/6/i) 
  end

  # Yellow squareYellow squareYellow square⬜⬜
  # Yellow square⬜⬜Green squareYellow square
  # ⬜⬜Green squareGreen squareGreen square


  def self.flag_by_type(wordle_match_type)
    case wordle_match_type.to_sym
    when :wordle_en
      "🇬🇧"
    when :wordle_it
      "🇮🇹"
    when :wordle_fr
      "It's 🇫🇷 foo or bar"
    when :nerdlegame
      "You 🧮 a string"
    when :wordle_ko
      "🇰🇷"
    when :lewdle
      "🛏️"
    else # question mark, also try: 🤔 or 👽 Alien
      "⁉️"
    end
  end
end 
# (Irina, Wurundjeri Land ☀️🌧❄️🍂🚃
