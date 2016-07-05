scheduler-web: rails s
dealer: cd lib;ruby dealer.rb;
celery-daemon: bundle exec rceleryd -t ./lib/celery/server.rb -a dister
interpreter: bundle exec ruby ./lib/celery/interpreter-daemon.rb -t ./lib/celery/interpreter.rb
worker-seapig: bundle exec seapig-worker ws://localhost:3001
server-seapig: bundle exec seapig-server
session-saver-seapig: bundle exec seapig-session-saver ws://localhost:3001
notifier-seapig: bundle exec seapig-notifier ws://localhost:3001