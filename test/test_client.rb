#!/usr/bin/env ruby

# Test Client for RubySyslog

require 'socket'
require 'timeout'

begin
  puts "Starting @ #{Time.now}"
  udp_threads = []
  1000.times do
	#sleep(rand(3))
    udp_threads << Thread.new do
      timeout(5) do
	    client = UDPSocket.new
  	    client.connect('localhost', 9514)
        client.send "A UDP log message", 0
      end
	  sleep(0.01)
	end
  end
  udp_threads.each {|t| t.join}
  
  tcp_threads = []
  100.times do
    tcp_threads << Thread.new do
      timeout(10) do
  	    client = TCPSocket.new('localhost', 9514)
	    client.puts "A TCP log message"
	    client.close
	  end
	  sleep(0.01)
	end
  end
  
  tcp_threads.each {|t| t.join}
rescue
  puts "error: #{$!}"
end

puts "Ending @ #{Time.now}"