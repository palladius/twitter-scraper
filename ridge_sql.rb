
sql = "SELECT TOP 100 U.\"id\", U.\"display_name\", COUNT(*)\nFROM \"twitter_users\" U\nLEFT OUTER JOIN \"tweets\" T\nON T.\"twitter_user_id\" = U.\"id\"\nGROUP BY U.\"id\", U.\"display_name\"\nORDER BY COUNT(*) DESC"

#         -- ISNULL(T.tweet_count, 0) AS tweet_count

sql = '
    SELECT 
        U.id, 
        U.name
    FROM twitter_users U
    LEFT OUTER JOIN 
        (SELECT twitter_user_id, COUNT(*) AS tweet_count
         FROM tweets
         GROUP BY twitter_user_id
    ) T
    ON T.twitter_user_id = U.id
    ORDER BY tweet_count DESC
'
 ActiveRecord::Base.connection.execute(sql)
