
VERSION = $(shell cat VERSION)

stats:
	echo Tweet.count | rails c
	echo TwitterUser.count | rails c
	echo "Now Riccardo magic:"
	echo WordleTweet.count | rails c
	
docker-build:
	docker build -t twitter-scraper-local .
	echo OK.
docker-run: 
	docker run -it --env-file .env -p 8080:8080 twitter-scraper-local ./entrypoint-8080.sh 
docker-run-bash: 
	docker run -it --env-file .env -p 8080:8080 twitter-scraper-local bash
docker-push: docker-build
	docker tag  twitter-scraper-local gcr.io/ric-cccwiki/twitter-scraper:v$(VERSION)
	docker push gcr.io/ric-cccwiki/twitter-scraper:v$(VERSION)
#      --add-cloudsql-instances PROJECT_ID:REGION:INSTANCE_NAME \
#--image gcr.io/PROJECT_ID/twitter-scraper \
     
deploy-to-cloud-run: docker-push
	touch ./deploy-to-cloud-run.sh
	dfksdhf kajs


test-build-push-deploy:
	bin/rails db:migrate RAILS_ENV=test
	rake test 
	make docker-build
	make docker-push 
	make deploy-to-cloud-run

ingest-batch-from-twitter:
	watch rake db:seed

run-prod:
	RAILS_ENV=production rails s