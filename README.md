# README

Welcome to `Teitter Scraper`

Created by ricc with ricc's rails-app-scaffolder (also called `meta-scaffolder`).
Config yaml here: rails-app-scaffolder-sample.yaml

TODO(test recreation by changing one thing - as the problem arises)

* Ruby version: 2.7.2

* System dependencies

* Configuration

* Database creation: rake db:migrate

* Database initialization: rake db:seed (this is AWESOME! It keeps parsing twits from the INTERNECHE ({*}))

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions: TODO

## install

Make sure you have Twitter APIs enabled. Instructions: TODO.

    cp .env.dist .env
    vim .env # edit away with your 3 vars.

See it in prod:

    https://twitter-scraper-v3ydafeb7q-ew.a.run.app/tweets/175313

## TODO

* Skaffold / Cloud Deploy / Tekton
* make `rake db:seed` be able to run in PROD on cloud run (probably via a HTTP GCF trigger and an endpoint I can call via Rails API.. like /actions/blah)
  so i dont need to leave my ocmputer run in background :) To do this, I need to add a background task which executes stuff in background to populate stuff. I see a few solutions: https://stackoverflow.com/questions/42260752/daemon-vs-runner-vs-rake-tasks-vs-active-job runner seems the best, but also Daemon could be interesting. Also a simple HTTP endpoint whcih i then call with GCF. Lets start with wrapping the action in a simple `Tweet.call_twitter_apis(search)`. Whatever happens, I need to converge the functionality in there. With both HTML and TXT output.
  On 26feb i've done that:

     * Created a HTTP endpoint under /games/actions/seed_by_search_term 
     * cofigured a Cloud Scheduler to call it every 3 minutes
     * no GCF was hurt or damaged during this sdocumentary :) Just Clud Scheduler (basically a `cron * * * * * curl http://URL/dowload_all`)
     * The only part was adding Twitter API keys to prod/staging which should be a big deal froms ecurity perspective. The alternative is to pass it as
       HTTP querystring param and it scares me a bit more.
     * link: https://console.cloud.google.com/cloudscheduler

## Notes

Created with my awesome `rails-app-scaffolder` code, soon open sourced if you ask me.
To understand how it works, juist look at the YAML and you'll immediately know what it does: `rails-app-scaffolder-sample.yaml`.
