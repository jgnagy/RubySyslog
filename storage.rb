module RubySyslog
  DEFAULT_STORAGE_CONFIG = {
	'development' => {
		'adapter'	=> 'sqlite3',
		'database'	=> 'db/development.sqlite3',
		'pool'		=>	5,
		'timeout'	=>	5000
	}
  }

  class Storage
	require         "rubygems"
    require         "yaml"
    require         "active_record"
	
	# Allows debug output to be specified later
    attr_accessor :verbose
	
	# The config
	attr_accessor :config
	
	# the loaded models
	attr_reader :loaded_models
	
	def initialize(config = {:db => DEFAULT_STORAGE_CONFIG})
		@verbose = config[:verbose]
		@config = config
		@loaded_models = []
	end
	
	# Connects to the database using the config file
    def connect
		# connects to the database using the pulled config
		ActiveRecord::Base.establish_connection(@config[:db])
    end # connect

    # Requires all the model files in the project (so we can do neat Rails-like db stuff)
    def load_models
		# creates an array of all the model files in the models directory
		#  the regex removes items that don't end in ".rb"
		models = Dir.new("models/").entries.sort.delete_if { |ext| !(ext =~ /.rb$/) }
      
		# load the models
		models.each do |model|
			require "models/#{model}"
			if @verbose
				puts "Loaded Model: #{model}"
			end # if debug
			@loaded_models << model
		end # models.each
	end # load_models
	
	# Methods below here are specific to the syslog server...
	
	# Creates a new Log object and saves it to the database. This method needs to be reworked
	# to better handle failed saves, because it can lock up the storage ThreadPool if all
	# storage threads are sleeping because of failed DB writes.
	def store_log(log)
		new_log = Log.new(
			:hostname	=> log.hostname,
			:msg		=> log.msg,
			:facility	=> log.facility,
			:severity	=> log.severity
		)
		begin
			new_log.save
		rescue
			puts "Saving log #{log.object_id.to_s(16)} failed. Retrying... (try tweaking the storage pool size)"
			sleep(1)
			retry
		end
	end # store_log
  end # class Storage
end