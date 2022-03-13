# https://stackoverflow.com/questions/3453262/how-to-strip-leading-and-trailing-quote-from-string-in-ruby#:~:text=It's%20not%20clear%20from%20your,your%20string%20with%20single%20quotes.
class String
    # needed to trim doublequotes which all of sudden appeared in my variables. OUCH!
    def trim(sep=/\s/)
        sep_source = sep.is_a?(Regexp) ? sep.source : Regexp.escape(sep)
        pattern = Regexp.new("\\A(#{sep_source})*(.*?)(#{sep_source})*\\z")
        self[pattern, 2]
    end

    def remove_external_doublequotes
        trim('"')
    end
end