#!/usr/bin/env ruby
require 'rubygems'
require 'rcelery'



module RCelery
	  def self.queue_name
		  "testing"
	  end
end

daemon = RCelery::Daemon.new(ARGV)
daemon.run

