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
    # m[1] = "5/6"
    m = tweet_text.match(/ ([0123456X]\/6)/i)
    # first char of first match,  m[0] => "5/6"
    initial_digit_or_char = m[1][0] rescue nil
    return 42 if initial_digit_or_char == "X"
    initial_digit_or_char
  end

  def flag
    WordleTweet.flag_by_type(wordle_type)
  end

  def nice_wordle_type
    "#{flag} #{wordle_type}"
  end

  # this parses and SAVES it/. So if you had a mistake you're writing it WRONG :/
  # some wordle apps do NOT support this (eejits!) so i remove the issue
  def parse_incrementalday_from_text
    #tweet_text = "Wordle 231 3/6"
    # possible ones:
    # blah blah 234 6/6
    # blah blah #234 6/6
    #m = tweet_text.match(/ (#)?(\d+) .\/6/i)
    #                       1   2      => m[2] is what you need
    m = tweet_text.match(/ (#)?(\d+) [0123456X]\/6/i)
    #puts "[parse_incrementalday_from_text][NON_BLOCKING] Issues matching day in '#{tweet_text}'" unless m
    m[2] rescue nil
  end

  def self.find_italian_orphans()
    # All by NIL :)
  end
  # I believe this shoiuld jhust be a bloody Class function :)
  #define_singleton_method :create_from_tweet do |tweet|
  def self.create_from_tweet(tweet)
    warn "[TEST] WordleTweet.create_from_tweet() based on tweet: #{tweet.excerpt rescue :err_excerpt}" if Rails.env == 'test'
    wt = WordleTweet.new
    wt.tweet = tweet
    wt.import_notes = "Not sure yet I should be doing it this way.."
    wt.wordle_type = wt.calculate_wordle_type
    wt.score = wt.parse_score_from_text()
    # TODO infer with some way, eg Wordle date for 232 is 5feb22.
    # wordle_date: date
    wt.wordle_incremental_day =  wt.parse_incrementalday_from_text()
    # import_version: integer
    wt.import_version = 5 # First version
    # CHANGELOG
    # v1 - Uswed to be the normal one
    # v2 2022-02-06 I've added created_at to Tweet based on ORIGINAL tweet.
    # v3 2022-02-08 Now worldle_en also parses X as trial. Before it gave OTHER.
    # v4 2022-02-09 import is the same but SCORE is computed better now it supports X (score = 42).
    # v5 2022-02-10 italian version is now better.. aggregated ciofeco into normal italian as it greps many. Also introduced a new ciofeco 4 for 3 letters between PAR and LE just to test how big is the icon.
    # import_notes: text
    save = wt.save
    puts "DEB save issues: #{save}" unless save
    save
  end



###### STATIC METHODS ###

  # returns TWO things: matches and id of
  # TODO(ricc): messo parole che parsa meglio ma poi dila non parsa bene non so perche..
  def self.extended_wordle_match_type(text,
    include_very_generic = true,
    exclude_wordle_english_for_debug=false,
    include_only_italian_for_debug=false)

    ## ITALIAN START

    # ParFlag of Italyle 369 3/6
    # Par🇮🇹l matches  /Par..le/i
    return :wordle_it  if text.match?(/Par..le \d+ [123456X]\/6/i)
    return :wordle_it  if text.match?(/Par🇮🇹le \d+ [123456X]\/6/i)

      # ParFlag of Italyle 369 3/6
      # PAR🇮🇹LE - perche diamine QUESTO greppa? Forse l'icona e piuin di due caratteri...
      return :wordle_it  if text.match?(/Par.+le \d+ [123456X]\/6/i)
      # Pietro version Par🇮🇹le 370 1/6 🟩🟩🟩🟩🟩
      # testiamo per poco il 1/2
      return :wordle_it4_3chars  if text.match?(/Par...le \d+ [123456X]\/6/i)
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
    return :wordle_de  if text.match?(/http:\/\/wordle-spielen.de.*\d+ .\/6/i)
    return :lewdle     if text.match?(/Lewdle \d+ .\/6/)

    return :nerdlegame if text.match?(/nerdlegame \d+ .\/6/i)

    return :wordle_ko  if text.match?(/#Korean #Wordle .* \d+ .\/6/)

    return :wordle_en  if text.match?(/Wordle \d+ [123456X]\/6/i) unless exclude_wordle_english_for_debug

    # multi page scenario...
    m = text.match(/https:\/\/wordlegame.org\/wordle-in-([a-z]+)\?/)
    if m
      puts "[extended_wordle_match_type] Matched string: #{m[1]}"
      return "wg_#{m[1] rescue :error }".to_sym # :wg_spanish
    end

    # Generic wordle - might want to remove in the future
    if include_very_generic
      return :other if text.match?(/ordle \d+ [123456X]\/6/i) unless exclude_wordle_english_for_debug
    end
    return nil
  end

  # This should be the only necessary thingy to CREATE a tweet. Them if the WT fails, i can do with next iterations
  def self.quick_match(txt)
    # ITA EN
    txt.match?(/(ordle|par..le) (#)?\d+ [123456X]\/6/i ) or
      # FR: https://twitter.com/search?q=wordlefr&src=typed_query
      txt.match?(/WordleFR.*#\d+ [123456X]\/6/i) or
      # BR OT: joguei https://t.co/TVFNN8ARo6 #36 2/6 *
      txt.match?(/joguei.*#\d+ [123456X]\/6/i)
  end

  # Yellow squareYellow squareYellow square⬜⬜
  # Yellow square⬜⬜Green squareYellow square
  # ⬜⬜Green squareGreen squareGreen square

  def stats
    ret = {}
    ret[:type] = wordle_type
    ret[:score] = score
    ret[:day] = parse_incrementalday_from_text
    ret[:length] = length
    ret[:valid_for_stats] = valid_for_stats?

    return ret
  end

  # if I create a valid? then it wont SAVE if invalid. I just want to remove validity.
  def valid_for_stats?
    return false if parse_incrementalday_from_text.nil?
    return false if score.nil?
    return false unless score.to_s.match /[123456X]/i
    true
  end

  def self.flag_by_type(wordle_match_type)
    # nil
    return "😞" if wordle_match_type.nil?

    # non nil
    case wordle_match_type.to_sym
    when :wordle_en
      "🇬🇧"
    when :wordle_it
    when :wg_italian
      "🇮🇹"
    when :wordle_pt
    when :wg_portuguese
      '🇵🇹'
    when :wg_spanish
      "🇪🇸"
    when :wordle_it1_ciofeco
      "🇮🇹"
    when :wordle_fr
      "🇫🇷"
    when :nerdlegame
      "🔢" # — Countin 🔢
    when :wordle_ko
      "🇰🇷"
    when :lewdle
      "🛏️"
    when :other
      "❓"
    else # question mark, also try: 🤔 or 👽 Alien
      puts "WARN: Unknown Type: #{wordle_match_type}"
      "⁉️"
    end
  end



  def self.global_average_score
    # => {1=>676, 5=>12107, 2=>3232, 4=>16528, 6=>5506, 0=>917, 3=>12016}
    distribution_hash = WordleTweet.group(:score).count.select{|x| x>=1 && x<=6}
    distribution_arr = distribution_hash.to_a
    numerator = distribution_arr.map{|score,card| score*card}.sum
    denominator = distribution_arr.map{|score,card| card}.sum
    numerator * 1.0 / denominator
  end
end
# (Irina, Wurundjeri Land ☀️🌧❄️🍂🚃
