
VERSION = $(shell cat VERSION)

stats:
	echo Rails.env | rails c
	echo Tweet.count | rails c
	echo TwitterUser.count | rails c
	echo "Now Riccardo magic:"
	echo WordleTweet.count | rails c

docker-build:
	docker build -t twitter-scraper-local .
	echo OK.
docker-run: docker-build
	docker run -it --env-file .env -p 8080:8080 twitter-scraper-local ./entrypoint-8080.sh
docker-run-bash:
	docker run -it --env-file .env -p 8080:8080 twitter-scraper-local bash
docker-push: docker-build
	docker tag  twitter-scraper-local gcr.io/ric-cccwiki/twitter-scraper:v$(VERSION)
	docker push gcr.io/ric-cccwiki/twitter-scraper:v$(VERSION)
#      --add-cloudsql-instances PROJECT_ID:REGION:INSTANCE_NAME \
#--image gcr.io/PROJECT_ID/twitter-scraper \

deploy-to-cloud-run: docker-push
	./deploy-to-cloud-run.sh

test-build-push-deploy:
	bin/rails db:migrate RAILS_ENV=test
	rake test
	make docker-build
	make docker-push
	make deploy-to-cloud-run

ingest-batch-from-twitter:
	TWITTER_INGEST_SIZE=52 watch -n 5 rake db:seed
ingest-to-prod-from-twitter:
	TWITTER_INGEST_SIZE=51 RAILS_ENV=production rake db:seed

run-prod:
	RAILS_ENV=production rails s

search-for-pizzorni-in-prod:
	echo 'TwitterUser.all.map{|u| [u.id, u.name] }.first(1000000).select{|id,name| name.match /pizzor/i}' | RAILS_ENV=production rails console
