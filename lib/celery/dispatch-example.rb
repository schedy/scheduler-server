require 'rubygems'
require 'rcelery'
require './lib/celery/config.rb'
require './lib/celery/interpreter.rb'



module RCelery
	  def self.queue_name
		  "testing"
	  end
end

RCelery.start(application: 'developer', host: CELERY_HOST, port: CELERY_PORT, username: CELERY_USER, password: CELERY_PASS)

include Testing

results = jfdi.delay()
sleep(5)
p :waiting
p results.wait


