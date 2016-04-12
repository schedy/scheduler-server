#!/bin/ruby

require 'rubygems'
require 'rcelery'
require './lib/celery/server.rb'
require './lib/celery/config.rb'
require 'awesome_print'

RCelery.start(application: 'dister', host: CELERY_HOST, port: CELERY_PORT, username: CELERY_USER, password: CELERY_PASS)

include Testing

input = JSON.parse(STDIN.read)
results = execute_tasks.delay(input)
puts JSON.dump(results.wait)

