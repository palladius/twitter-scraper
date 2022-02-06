


stats:
	echo Tweet.count | rails c
	echo TwitterUser.count | rails c
	yellow "Now Riccardo magic:"
	echo WordleTweet.count | rails c
	
docker-build:
	docker build -t twitter-scraper-removeme .
	echo OK.
docker-run: 
	docker run -it -p 8080:8080 twitter-scraper-removeme ./entrypoint-8080.sh 
docker-run-bash: 
	docker run -it -p 8080:8080 twitter-scraper-removeme bash
docker-push:
	docker tag  twitter-scraper-removeme palladius/twitter-scraper
	docker push palladius/twitter-scraper
#      --add-cloudsql-instances PROJECT_ID:REGION:INSTANCE_NAME \
#--image gcr.io/PROJECT_ID/twitter-scraper \
     
deploy-to-cloud-run:
	gcloud run deploy twitter-scraper \
     --platform managed \
     --region europe-west1 \
     --image palladius/twitter-scraper \
     --allow-unauthenticated


ingest-batch-from-twitter:
	watch rake db:seed