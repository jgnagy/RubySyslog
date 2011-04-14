module RubySyslog
  require 'thread'
  
  class Parser
	# Allows accessing and altering the configuration of the Syslog parser
    attr_accessor :config
	
	def initialize(config = {:verbose => false})
		require 'lib/syslogproto'
		puts "SyslogProto parser loaded [  OK  ]" if config[:verbose]
		@config = config
	end
	
	# Parses packets and returns / yields the syslog object, depending on
	# if a block was passed
	def parse(packet)
		if block_given?
			yield SyslogProto.parse(packet)
		else
			return SyslogProto.parse(packet)
		end
	end
	
	# Class method for accessing the parse() method without creating an instance
	# of the Parser class
	def self.quick_parse(packet)
		return parse(packet)
	end
  end
  
  class LogQueue < Queue
	attr_accessor :lock
	
	def initialize
		@lock = false
	end
	
	def locked?
		return @lock
	end
	
	def flush!
		clear
	end
  end
  
  class LogMutex < Mutex
  end
end