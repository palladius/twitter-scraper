class TwitterUser < ApplicationRecord
    validates_uniqueness_of :twitter_id

    def to_s
        "@#{self.twitter_id}"
    end
end
