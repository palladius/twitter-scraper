
  # create_table "wordle_tweets", force: :cascade do |t|
  #   t.string "wordle_type"
  #   t.integer "tweet_id", null: false
  #   t.integer "score"
  #   t.date "wordle_date"
  #   t.string "wordle_incremental_day"
  #   t.datetime "created_at", precision: 6, null: false
  #   t.datetime "updated_at", precision: 6, null: false
  #   t.string "import_version"
  #   t.string "import_notes"
  #   t.string "internal_stuff"
  #   t.integer "max_tries"
  #   t.index ["tweet_id"], name: "index_wordle_tweets_on_tweet_id"
  # end


class WordleTweet < ApplicationRecord
  belongs_to :tweet
  validates_presence_of :score, on: :create
  validates_presence_of :wordle_type, on: :create # added on 18feb20

  DAY_AND_SCORE_REGEX = /\d+ [123456X]\/6| 💀\/6/ # most people use this, eg "123 4/6" or "#123 X/6".
  # Also wordle FR uses this for X: Le Mot (@WordleFR) #38 💀/6
  WORDLEGAME_LIST = %w{ spanish russian portuguese german italian kids english_uk }
  FILE_GREEN_SQUARES_REGEX = /🟩🟩🟩🟩🟩/# these are 5 greens

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

  def self.extended_wordle_match_type(txt, config = {})
    #config[] || = false
    try_new = config.fetch(:try_new, false)
    # TODO use internal_stuff to tweak behaviour
    return WordleTweet.extended_wordle_match_type_new_ancora_buggy_but_scalable(txt) if try_new
    # DEFAULT: OLD
    return WordleTweet.extended_wordle_match_type_old_ma_funge(txt)
  end

  # def calculate_wordle_type()
  #   extended_wordle_match_type(tweet_text, :try_new => false )
  # end

  # If it returns NIL, it will throw an ewxception as score cant be NULL :)
  # If you catcha  GOOD exception, return 42.
  def parse_score_from_text
    # m[1] = "5/6"
      # Sedecordle and Quordle dont have a good move system => returning alternative to 42 :)
    return 43 if tweet_text.match? /sedecordle.com/i # and maybe strengthen with these icons: 🕗🕖🕔🕕
    return 44 if tweet_text.match? /quordle/i
    #return 84 if tweet_text.match?(/6️⃣7️⃣3️⃣4️⃣🕔🕓🕖]/)  
    m = tweet_text.match(/ ([0123456X💀]\/6)/i)
    # first char of first match,  m[0] => "5/6"
    initial_digit_or_char = m[1][0] rescue nil
    #puts "DEB initial score: ''''#{initial_digit_or_char}''"
    return 42 if initial_digit_or_char == "X"
    return 42 if initial_digit_or_char == "💀" # Damn french wordle!
    initial_digit_or_char
  end

  def flag
    WordleTweet.flag_by_type(wordle_type)
  end

  def nice_wordle_type
    "#{flag} #{wordle_type}"
  end

  def extract_colored_squared
    ["TODO(ricc) should look like this, maybe even possibly:",
    "🟩🟩🟩🟩⬜",
    "🟩🟩🟩🟩🟩"
  ]
  end

  # this parses and SAVES it/. So if you had a mistake you're writing it WRONG :/
  # some wordle apps do NOT support this (eejits!) so i remove the issue
  def parse_incrementalday_from_text
    #tweet_text = "Wordle 231 3/6"
    # possible ones:
    # blah blah 234 6/6
    # blah blah #234 6/6
    # Can you guess this word?  https://wordlegame.org/?challenge=Ymx1c2g… https://wordlegame.org
    # https://wordlegame.org/?challenge=Ymx1c2g
    # https://wordlegame.org/?challenge=YXByaWw
    #m = tweet_text.match(/ (#)?(\d+) .\/6/i)
    #                       1   2      => m[2] is what you need
    # Case 1: normal
    m = tweet_text.match(/ (#)?(\d+) [0123456X]\/6/i)
    return "int/#{m[2]}" if (m[2] rescue nil)

    # Case 2.
    m = tweet_text.match(/wordlegame.org\/\?challenge=([a-zA-Z0-9]+)/i)
    return "wg/#{m[1]}" if (m[1] rescue nil)

    #puts "[parse_incrementalday_from_text][NON_BLOCKING] Issues matching day in '#{tweet_text}'" unless m
    #m[2] rescue nil
    return nil
  end

  # TODO deprecate this
  def self.find_italian_orphans()
    # All by NIL :)
  end

  def daily_id
    # todo scrape int/123
    wordle_incremental_day.gsub("int/","") rescue :WTdaily_id_SomeError
  end

  def game 
    "#{wordle_type}::#{daily_id}" # rescue :WTGame_SomeError
  end

  # I believe this shoiuld jhust be a bloody Class function :)
  #define_singleton_method :create_from_tweet do |tweet|
  def self.create_from_tweet(tweet, opts={})
    opts_try_new = opts.fetch :try_new, false

    warn "[TEST] WordleTweet.create_from_tweet() based on tweet: #{tweet.excerpt rescue :err_excerpt}" if Rails.env == 'test'
    wt = WordleTweet.new
    wt.tweet = tweet
    wt.import_notes = "Created on #{Time.now}"
    wt.max_tries = 6
    wt.internal_stuff = ''
    wt.wordle_type = WordleTweet.extended_wordle_match_type(wt.tweet_text, :try_new => opts_try_new ) rescue nil # wt.calculate_wordle_type
    wt.score = wt.parse_score_from_text()
    # TODO infer with some way, eg Wordle date for 232 is 5feb22.
    # wordle_date: date
    wt.wordle_incremental_day =  wt.parse_incrementalday_from_text()
    # import_version: integer
    wt.import_version = 7 
    # CHANGELOG
    # v7 2022-02-13 removed import notes. Added max_tries=6
    # v6 2022-02-11 Added :taylordle plus a number of generic .
    # v5 2022-02-10 italian version is now better.. aggregated ciofeco into normal italian as it greps many. Also introduced a new ciofeco 4 for 3 letters between PAR and LE just to test how big is the icon.
    # v1 - Uswed to be the normal one
    # v2 2022-02-06 I've added created_at to Tweet based on ORIGINAL tweet.
    # v3 2022-02-08 Now worldle_en also parses X as trial. Before it gave OTHER.
    # v4 2022-02-09 import is the same but SCORE is computed better now it supports X (score = 42).
    # import_notes: text
    save = wt.save
    puts "DEB save issues: #{save} [TXT:'#{wt.tweet_text.gsub("\n","") rescue :err}', ERRORS='#{red wt.errors.full_messages}']" unless save
    #puts "DEB save issues: #{save} [TXT:'#{wt.tweet_text.gsub("\n","") rescue :err}']" unless save
    return save
  end

# Regexes in order... so WORDLE shoudl be LAST
# moved to YAML :) -> config/wordle-regexes.yml

def self.extended_wordle_match_type_new_ancora_buggy_but_scalable(text, opts={})
  debug = opts.fetch :debug, false

  puts "[deb] extended_wordle_match_type_new_ancora_buggy_but_scalable REMOVEME" if debug
  # before searching like crazy i make sure some initisal regex is matched :)
#  unless text.match?(/\d+ [123456X]\/6/i) or text.match? /wordlegame.org\/wordle/
  #unless text.match?(/\d+ [123456X]\/6/i) or text.match? /wordlegame.org\/wordle/
  unless text_matches_moves(text)
      puts "[WARNING] BAD_TEXT_001: No 123 X/6 found or wordlegame.org - skipping: #{text}"
    return nil
    # Example of bad text: "No 123 X/6 found or even - skipping: Can you guess this Polish word?https://wordlegame.org/wordle-in-polish?challenge=xZtsZXB5"
    # wordlegame.org when you do NOT guess in first 6. The regex doesnt contain response.
  end

  p WORDLE_REGEXES if debug
  WORDLE_REGEXES.each{|h|

    #p "+ WORDLE_REGEXES hash: ", h # if debug
    raise "Missing fundamental Key: RETURN for #{h}" unless h.key?(:return)
    h[:regexes_in_or].each {|regex| 
      puts "DEB: Checking regex #{yellow regex} for text #{white text}.." if debug
      ret = text.match?(/#{regex}/) #?   h[:return].to_sym :     nil 
      #p("ret=#{ret} h[:return]=#{h[:return]}") # if debug
      # only return if TRUE if not continue to iterate..
      return h[:return].to_sym  if ret == true
    } if h[:regexes_in_or]
  }

  p "now lets try worldegame.. matcha? text='#{text}'" if debug

  # Case 2: Lets now manage 
  # - https://wordlegame.org/wordle-in-english-uk
  # - https://wordlegame.org/wordle-in-russian
  # - https://wordlegame.org/wordle-for-kids
#  polymorphic_match = text.match(/wordlegame.org\/wordle-in-([a-z-]+)/i)
  polymorphic_match = text.match(/wordlegame.org\/wordle-(in|for)-([a-zA-Z-]+)/i)
  if polymorphic_match
    parsed_language =  polymorphic_match[2] rescue :error 
    puts "[extended_wordle_match_type v2] Matched string: '#{yellow parsed_language}'"
    return "wg_#{parsed_language}".to_sym # :wg_spanish
    #return :todo
  else 
    p "DEB desculpe no mathch: polymorphic_match=#{white polymorphic_match}"
  end

  # nothing. I throw the sponge.
  return :unknown_v2
end

##########################
###### STATIC METHODS ###
##########################

  # This matches. For the extractions see above
  def self.text_matches_moves(text)
    text.match?(/\d+ [123456X]\/6/i) or text.match?(/in [123456X💀]\/6 tries/i) or text.match?(/[6️⃣7️⃣3️⃣4️⃣]/i) or text.match?(/💀\/6/)
  end

  # returns TWO things: matches and id of
  # TODO(ricc): messo parole che parsa meglio ma poi dila non parsa bene non so perche..
  def self.extended_wordle_match_type_old_ma_funge(text,
    include_very_generic = false)

    # first obvious check - make sure it has a
#    unless text.match?(/\d+ [123456X]\/6/i) or text.match?(/in [123456X]\/6 tries/i) or text.match?(/[6️⃣7️⃣3️⃣4️⃣]/i) 
    unless  self.text_matches_moves(text)
      puts "[WARN] BAD_TEXT_002 No 123 X/6 found or even wordlegame tries - skipping: TEXT='''#{white text.gsub("\n",'')}'''"
      return nil
    end

    ## ITALIAN START

    # ParFlag of Italyle 369 3/6
    # Par🇮🇹l matches  /Par..le/i
    #return :wordle_it  if text.match?(/Par..le \d+ [123456X]\/6/i)
    return :wordle_it  if text.match?(/Par🇮🇹le \d+/i) and text.match?(DAY_AND_SCORE_REGEX)

      # ParFlag of Italyle 369 3/6
      # PAR🇮🇹LE - perche diamine QUESTO greppa? Forse l'icona e piuin di due caratteri...
      return :wordle_it  if text.match?(/Par.+le \d+/i) and text.match?(DAY_AND_SCORE_REGEX)
      # Pietro version Par🇮🇹le 370 1/6 🟩🟩🟩🟩🟩
      # testiamo per poco il 1/2
      return :wordle_it  if text.match?(/Par...le \d+/i) and text.match?(DAY_AND_SCORE_REGEX)
      return :wordle_it  if text.match?(/Par🇮🇹le \d+ .\/6/i)
      return :wordle_it  if text.match?(/par.+le \d+ .\/6/i) and text.match?(DAY_AND_SCORE_REGEX)

      return :wordle_it  if text.match?(/Wordle \(IT\).*\d+/i)

      return :wordle_es  if text.match?(/Wordle \(ES\).*\d+/i)
      return :wordle_es  if text.match?(/wordle.danielfrg.com/i)
      
          

    ## ITALIAN END
    #return nil if include_only_italian_for_debug

    # returns TWO things: matches and id of
    return :wordle_fr  if text.match?(/Le Mot \(@WordleFR\) \#\d+/i) and text.match?(DAY_AND_SCORE_REGEX)
    # "joguei http://term.ooo #34 X/6 *"
    return :wordle_pt  if text.match?(/joguei http:\/\/term.ooo \#\d+/i ) and text.match?(DAY_AND_SCORE_REGEX)

    # TODO ricc: non so quale dei due e vado di fretta
    return :wordle_pt  if text.match?(/term.ooo \d+/i ) and text.match?(DAY_AND_SCORE_REGEX)
    return :wordle_pt  if text.match?(/term.ooo [#]\d+/i ) and text.match?(DAY_AND_SCORE_REGEX)
    # siccome fallisce... provo questo. 
    # Twitter substityutes the portiguese term.ooo with this: https://t.co/SOMETHING so however brittle I'll
    # match: "joguei  https://t.co/" there you go. This also explains the other URLs...
    return :wordle_br  if text.match?(/joguei https:\/\/t.co\//i) and text.match?(DAY_AND_SCORE_REGEX)

    # I cant remember wha website was this.
    return :wg_german  if text.match?(/I guessed this German 5-letter word in .\/6 tries/)
    return :wg_german  if text.match?(/Ich habe dieses deutsche 5-Buchstaben Wort in .\/6 Versuchen/i)
    # This is better
    return :wordle_de  if text.match?(/wordle-spielen.de.*\d+/i) and text.match?(DAY_AND_SCORE_REGEX)
     
    return :lewdle     if text.match?(/Lewdle \d+/) and text.match?(DAY_AND_SCORE_REGEX)

    # Math :)
    return :nerdlegame if text.match?(/nerdlegame \d+/i) and text.match?(DAY_AND_SCORE_REGEX)
    # note the medium needs to be AFTER the other two...
    return :mathler_hard   if text.match?(/hard.mathler.com/i) and text.match?(DAY_AND_SCORE_REGEX)
    return :mathler_easy   if text.match?(/easy.mathler.com/i) #and text.match?(DAY_AND_SCORE_REGEX)
    return :mathler_medium if text.match?(/mathler.com/i) and text.match?(DAY_AND_SCORE_REGEX)


    # Geographical
    return :worldle if text.match?(/worldle.teuteuf.fr/i) and text.match?(DAY_AND_SCORE_REGEX)

    return :wordle_ko  if text.match?(/#Korean #Wordle .* \d+/i) and text.match?(DAY_AND_SCORE_REGEX)
 
    # malayisian
    return :katla if text.match?(/katla /i) and text.match?(DAY_AND_SCORE_REGEX)
    return :katapat if text.match?(/Katapat/i)  and text.match?(DAY_AND_SCORE_REGEX)

    # SUTOM (FRench more than 5 letter)
    return :sutom if text.match?(/sutom/i)  and text.match?(DAY_AND_SCORE_REGEX)

    # https://www.taylordle.com/
    return :taylordle if text.match?(/Taylordle \d+ [123456X]\/6/i)

    # multiple wordles: 4, 16, ..
    return :quordle if text.match?(/Quordle #\d+/) and text.match?(/[6️⃣7️⃣3️⃣4️⃣]/) and text.match?(FILE_GREEN_SQUARES_REGEX) # and 🟩🟩🟩🟩🟩
    return :sedecordle if text.match?(/Daily sedecordle #\d+/)
    # multi page polymorphic scenario... 
    # wg_italian
    # wg_spanish
    # wg_XXX
    m = text.match(/https:\/\/wordlegame.org\/wordle-(in|for)-([-a-z]+)\?/)
    if m
      # Examples with dash: 
      # https://wordlegame.org/wordle-for-kids?challenge=c2Nvd2w 
      # https://wordlegame.org/wordle-in-english-uk?challenge=Y2FtZWw 
      language = (m[2] rescue "error").gsub("-","_")
      return "wg_#{language}".to_sym # :wg_spanish or :wg_english_uk
    end

    #       Wordle (IT) 240 4/6     ⬇️ ⬇️ ⬇️ ⬇️ ⬇️   https://wordle.wekele.com
    #
    m = text.match(/Wordle \((..)\).*wordle.wekele.com/) and text.match?(DAY_AND_SCORE_REGEX)
    if m
      # Examples with dash: 
      # https://wordlegame.org/wordle-for-kids?challenge=c2Nvd2w 
      # https://wordlegame.org/wordle-in-english-uk?challenge=Y2FtZWw 
      language = (m[1] rescue "error").gsub("-","_")
      return "wekele_#{language}".to_sym # :wg_spanish or :wg_english_uk
    end


    # Generic wordle - might want to remove in the future
    # 1. English we keep last
    return :wordle_en  if text.match?(/Wordle \d+ [123456X]\/6/i) 

    # otherwise... and fail :)
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

  def safe_text
    text.gsub("\n","")
  end

  # 42 is X or NEVER
  def score_str
    return 'X' if score==42 
    score.to_s 
  end

  def stats
    ret = {}
    ret[:type] = wordle_type
    ret[:flag] = flag #  WordleTweet.flag_by_type(wordle_type)
    ret[:score_db] = score
    ret[:score_db_s] = score_str
    ret[:score_calculated] = parse_score_from_text # might be expensive to calculate
    
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
      when :wg_english_uk
        "🏴󠁧󠁢󠁥󠁮󠁧󠁿"
      when :wordle_it, :wg_italian,  :wordle_it1_ciofeco, :wekele_it # todo many others :)
        "🇮🇹"
      when :wordle_pt, :wg_portuguese
        '🇵🇹'
      when :wordle_br
        '🇧🇷'
      when :wg_spanish, :wordle_es
        "🇪🇸"
      when :wg_russian
        "🇷🇺"
      when :katapat, :katla
        "🇲🇾"
      when :wordle_fr, :sutom
        "🇫🇷"
      when :wordle_de, :wg_german
        "🇩🇪"
      when :nerdlegame
        "🔢" 
      when :mathler_medium, :mathler_hard, :mathler_easy
        "🔢"
      when :wordle_ko
        "🇰🇷"
      when :lewdle
        "🛏️"
      when :taylordle
        "💕"
      when :worldle
        "🌎"
      when :wg_kids
        "🧒"
      when :quordle
        "4️⃣"
      when :sedecordle
        "🔟"
      when :other
        "❓"
      else # question mark, also try: 🤔 or 👽 Alien
        puts "[flag_by_type] WARN: Unknown Type: #{wordle_match_type}"
        return "⁉️"
      end
  end

  def self.acceptable_types
    static_acceptable = WORDLE_REGEXES.map{|h| h[:return]}
    acceptables = static_acceptable + WORDLEGAME_LIST.map{|x| "wg_#{x}"}
    acceptables.sort
  end


  def self.global_average_score
    # => {1=>676, 5=>12107, 2=>3232, 4=>16528, 6=>5506, 0=>917, 3=>12016}
    distribution_hash = WordleTweet.group(:score).count.select{|k,v| not k.nil?}.select{|x| x>=1 && x<=6}
    distribution_arr = distribution_hash.to_a
    numerator = distribution_arr.map{|score,card| score*card}.sum
    denominator = distribution_arr.map{|score,card| card}.sum
    numerator * 1.0 / denominator
  end


  # trying to uniform the concept of avergae ALL across this thing
  def self.averagization(array_of_scores)
    # https://stackoverflow.com/questions/1341271/how-do-i-create-an-average-from-a-ruby-array
    # recalculate 42 as a different thingy maybe 42 is now 7, 8, or 7.5 :)
    array_of_scores.inject{ |sum, el| sum + el }.to_f / array_of_scores.size
  end

  # Takes source like this: => {1=>4, 42=>32, 2=>24, 5=>250, 4=>223, 6=>143, 3=>129}
  # and returns average
  # https://stackoverflow.com/questions/17750258/cumulative-weighted-average-in-ruby
  # WOOOOT!
  def   self.average_score_for(hash_of_results) 
#    cs=0 ; qu=0 
    cumulative_numerator, cumulative_denominator = 0.0, 0.0
    num_den = hash_of_results.map{|score, card| [cumulative_numerator += score * card, cumulative_denominator += card ]}.last # => [23915.0, 3283.0]
    num_den.first / num_den.second
  end


  # given     🕔🕓1️⃣3️⃣ 4️⃣2️⃣ 🕖4️⃣ 6️⃣5️⃣ 7️⃣🕒 🕗8️⃣ 9️⃣🕑 🕕🔟 🕐🕛
  # returns the max
  # TODO
  def self.extract_best_score_from_numeric_emojis(txt)
    extracted_icons = txt.match(/6️⃣/)
    return 42 unless extracted_icons
    return 21
  end

# ["wordle_ko", "34"]=>1,
# ["wordle_ko", "int/44"]=>1,
# ["wordle_ko", "int/47"]=>1,
# ["wordle_ko", "int/48"]=>2,
# ["wordle_pt", "41"]=>1}
# game = "#{wordle_type}::#{daily_id}"
  def self.group_by_game(opts={})
    last_ndays = opts.fetch :last_ndays, 3 
    
    WordleTweet.group(:wordle_type, :wordle_incremental_day).count.map{|wt_and_wid, cardinality|
      ["#{wt_and_wid.first}::#{wt_and_wid.second.gsub("int/","") rescue wt_and_wid.second }", cardinality]
    }
   # todo metti ultimi 10 giorni o ultimo giorno via opts...
  end
 # pgsql irb(main):001:0> WordleTweet.select('DISTINCT ON ("wordle_incremental_day") *').order(:wordle_incremental_day, date: :desc, id: :desc)
end
