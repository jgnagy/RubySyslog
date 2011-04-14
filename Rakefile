require 'active_record'
require 'yaml'

task :default => :migrate

desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
task :migrate => :environment do
  ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
end

task :environment do
  config = YAML::load_file('config.yaml')
  #puts config.to_yaml
  ActiveRecord::Base.establish_connection(config[:db])
  ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
end