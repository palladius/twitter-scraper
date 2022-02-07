# Should map to Twitter User Object: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
class TwitterUser < ApplicationRecord
    validates_uniqueness_of :twitter_id

    def url 
        "http://twitter.com/#{username}"
    end
    def url_by_id 
       # https://stackoverflow.com/questions/4132900/url-link-to-twitter-user-with-id-not-name
        "https://twitter.com/intent/user?user_id=#{twitter_id}"
    end

    def accountid
        twitter_id
    end
    def to_s(verbose=false)
        return "TwitterUser @#{self.twitter_id} #{url_by_id}" if verbose
        "@#{self.twitter_id}"
    end
end
