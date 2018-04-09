scheduler-web: rails s -p 3000
server-seapig: bundle exec seapig-server -v 
dealer: cd bin; bundle exec ruby bin/dealer ws://127.0.0.1:3001 http://127.0.0.1:81
worker-seapig: bundle exec seapig-worker -c ws://127.0.0.1:3001
session-manager-seapig: bundle exec seapig-router-session-manager -c ws://127.0.0.1:3001
notifier-seapig: bundle exec seapig-postgresql-notifier