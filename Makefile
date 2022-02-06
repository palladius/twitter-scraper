
VERSION = $(shell cat VERSION)

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
	docker tag  twitter-scraper-removeme gcr.io/ric-cccwiki/twitter-scraper:v$(VERSION)
	docker push gcr.io/ric-cccwiki/twitter-scraper:v$(VERSION)
#      --add-cloudsql-instances PROJECT_ID:REGION:INSTANCE_NAME \
#--image gcr.io/PROJECT_ID/twitter-scraper \
     
deploy-to-cloud-run:
	gcloud run deploy twitter-scraper \
     --platform managed \
     --region europe-west1 \
     --image gcr.io/ric-cccwiki/twitter-scraper:v$(VERSION) \
     --allow-unauthenticated


ingest-batch-from-twitter:
	watch rake db:seed