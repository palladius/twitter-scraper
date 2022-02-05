# Should map to Twitter User Object: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
class TwitterUser < ApplicationRecord
    validates_uniqueness_of :twitter_id

    def url 
        "http://twitter.com/#{username}"
    end
    def to_s
        "@#{self.twitter_id}"
    end
end
