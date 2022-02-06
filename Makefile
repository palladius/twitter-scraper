


stats:
	echo Tweet.count | rails c
	echo TwitterUser.count | rails c
	yellow "Now Riccardo magic:"
	echo WordleTweet.count | rails c
	
docker-build:
	docker build -t twitter-scraper-removeme .

ingest-batch-from-twitter:
	watch rake db:seed