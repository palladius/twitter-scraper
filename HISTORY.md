
* `2022-02-26` 1.2.14  From today the system is able to do db:seed via URL: /games/actions/seed its a very SLOW thing, lets see if theres a better way to do it.
* `2022-02-19` 1.2.04  big fix to rake db:seed: break vs next it always returned after a single failed regex match.
* `2022-02-19` 1.2.01  MAJOR. Added `WordleGame` model as a cheap destroy-recreate intelligent thingy
* `2022-02-19` *1.1.01* MAJOR. Added migration for DelayedJob https://github.com/collectiveidea/delayed_job_active_record