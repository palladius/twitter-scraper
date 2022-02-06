


stats:
	echo Tweet.count | rails c
	echo TwitterUser.count | rails c
	yellow "Now Riccardo magic:"
	echo WordleTweet.count | rails c
	
ingest-batch-from-twitter:
	watch rake db:seed