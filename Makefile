
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

deploy-to-cloud-run-prod: docker-push
	./deploy-to-cloud-run.sh
deploy-to-cloud-run-staging: docker-push
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
ingest-to-prod-once:
	TWITTER_INGEST_SIZE=123 RAILS_ENV=production rake db:seed
ingest-to-prod-whilesleep:
	while true; do make ingest-to-prod-once ; sleep 60 ; done

ingest-to-staging-once:
	TWITTER_INGEST_SIZE=21 RAILS_ENV=staging rake db:seed

ingest-to-dev-once:
	TWITTER_INGEST_SIZE=153 MARSHAL_TO_FILE=true RAILS_ENV=development rake db:seed
ingest-to-dev-continuously:
	while true; do make ingest-to-dev-once ; sleep 10 ; done
ingest-to-devpg-once:
	TWITTER_INGEST_SIZE=54 RAILS_ENV=devpg rake db:seed

run-prod:
	RAILS_ENV=production rails s
run-devpg:
	 RAILS_ENV=devpg rails s

# prod:
# PROD Nick:  [[236089, "BJArmstrong10", "Nicola Piludu"]]
# PROD Pizzo: [[168301, "PaoloPizzorni", "Paolo Pizzorni"]]
search-for-pizzorni-and-piludu-in-prod:
	echo 'TwitterUser.all.first(10000000).map{|u| [u.id, u.ldap, u.name] }.select{|id,name, description| name.match? /BJArmstrong10|palladius/i}' | RAILS_ENV=production rails console
	echo 'TwitterUser.all.first(10000000).map{|u| [u.id, u.ldap, u.name] }.select{|id,name, description| name.match? /pizzorn/i}' | RAILS_ENV=production rails console
test-fixtures:
	RAILS_ENV=test rake db:fixtures:load

boost-cloud-run:
	gcloud run services update twitter-scraper-staging --no-cpu-throttling --region europe-west1
	gcloud run services update twitter-scraper --no-cpu-throttling --region europe-west1
	gcloud run services describe twitter-scraper  --region europe-west1

ridge-optimized-query:
	cat ridge_sql.rb | RAILS_ENV=devpg rails c
