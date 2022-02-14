
VERSION = $(shell cat VERSION)
LOCAL_DOCKER_APP = twitter-wordle-scraper-deleteme:v$(VERSION)

stats:
	RAILS_ENV=development rake db:sbirciatina
	RAILS_ENV=production  rake db:sbirciatina
	RAILS_ENV=staging     rake db:sbirciatina

staging-stats:
	RAILS_ENV=staging rake db:sbirciatina || echo Error
	@echo e ora vediamo in PROD:
	RAILS_ENV=production rake db:sbirciatina

staging-check-db:
	RAILS_ENV=staging DATABASE_URL=postgres://twitter-scraper:MannaggiaUPatataughTwitter@34.65.100.166:5432/twitter-scraper-staging rake

prod-stats:
	RAILS_ENV=production rake db:sbirciatina

docker-build:
	docker build -t $(LOCAL_DOCKER_APP) .
	echo OK.
docker-run: docker-build
#	docker run -it --env-file .env -p 8080:8080 $(LOCAL_DOCKER_APP) ./entrypoint-8080.sh
	make docker-run-nodep
docker-run-nodep:
  #@echo Ignoring dependencies...
	docker run -it --env-file .env -p 8080:8080 $(LOCAL_DOCKER_APP) ./entrypoint-8080.sh
docker-run-bash:
	docker run -it --env-file .env -p 8080:8080 $(LOCAL_DOCKER_APP) bash
docker-push: docker-build
	docker tag  $(LOCAL_DOCKER_APP) gcr.io/ric-cccwiki/twitter-scraper:v$(VERSION)
	docker push gcr.io/ric-cccwiki/twitter-scraper:v$(VERSION)
#      --add-cloudsql-instances PROJECT_ID:REGION:INSTANCE_NAME \
#--image gcr.io/PROJECT_ID/twitter-scraper \

deploy-to-cloud-run: docker-push
	./deploy-to-cloud-run.sh
deploy-staging-to-cloud-run: docker-push
	./deploy-staging-to-cloud-run.sh

test-build-push-deploy:
	bin/rails db:migrate RAILS_ENV=test
	rake test
	make docker-build
	make docker-push
	make deploy-to-cloud-run

ingest-batch-from-twitter:
	@echo [IMPORTANT] Works for both DEV and PROD. try:
	@echo [IMPORTANT] Try this in PROD: RAILS_ENV=production make ingest-batch-from-twitter
	@echo [IMPORTANT] do NOT use WATCH. Use WHILE instead - pirla. 
	TWITTER_INGEST_SIZE=201 watch -n 10 rake db:seed
# this uses a while, not wATCH so its better suited for long computations.
ingest-bacth-prod-while:
	while true; do make TWITTER_INGEST_SIZE=121 RAILS_ENV=production ingest-to-prod-from-twitter ; sleep 10 ; done
ingest-to-prod-from-twitter:
	TWITTER_INGEST_SIZE=151 RAILS_ENV=production rake db:seed
ingest-to-staging-from-twitter:
	TWITTER_INGEST_SIZE=51 RAILS_ENV=staging rake db:seed
ingest-to-dev-from-twitter:
	TWITTER_INGEST_SIZE=153 RAILS_ENV=development rake db:seed

run-prod:
	RAILS_ENV=production rails s

search-for-pizzorni-in-prod:
	echo 'TwitterUser.all.map{|u| [u.id, u.name] }.first(1000000).select{|id,name| name.match /pizzor/i}' | RAILS_ENV=production rails console

test-fixtures:
	RAILS_ENV=test rake db:fixtures:load
