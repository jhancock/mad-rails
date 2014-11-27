# rails r lib/scripts/migrate_v2.0/migrate_v2.0.rb  ~/mongo_dump/lin1-20141102082738.tar.gz ~/migrate_v2.0 > ~/migrate_v2.0.txt
# ARGV[0] - path to tar.gz.  Dump of mhd_v1.0 mongodb
# ARGV[1] - temp working directory.  will create if does not exist. 

require 'fileutils'

abort "must pass two arguments to this script" unless ARGV.size == 2
db = Rails.env.production? ? "mhd_production" : "mhd_development"
original_db_archive_path = ARGV[0]
working_directory = ARGV[1]

puts "Rails ENV=#{Rails.env}"
puts "...migrate into db: #{db}"
puts "...using db dump: #{original_db_archive_path}"
puts "...working directory: #{working_directory}"

abort "#{original_db_archive_path} not found" unless File.exists?(original_db_archive_path)
FileUtils::mkdir_p working_directory unless Dir.exists?(working_directory)

db_archive = File.basename original_db_archive_path
db_archive_name = File.basename original_db_archive_path, ".tar.gz"

puts "cp #{original_db_archive_path} #{working_directory}/#{db_archive}"
system "cp #{original_db_archive_path} #{working_directory}/#{db_archive}"
puts "extracting archive to working directory..."
system "rm -rf #{working_directory}/#{db_archive_name}"
#system "rmdir #{working_directory}/#{db_archive_name}"
system "tar zxvf #{working_directory}/#{db_archive} -C #{working_directory}"

system "mv #{working_directory}/#{db_archive_name}/mhd_production #{working_directory}/#{db_archive_name}/mhd_development" if Rails.env.development?

mongo_collection_path = "#{working_directory}/#{db_archive_name}/#{db}"

system "rmdir #{working_directory}/#{db_archive_name}/admin" 
system "rm #{mongo_collection_path}/system.indexes.bson"
system "rm #{mongo_collection_path}/event_log.bson"
system "rm #{mongo_collection_path}/mail_log.bson"
system "rm #{mongo_collection_path}/books_offline_history.bson"

# from mongo shell command line:
# > mongo mhd_development
# > use mhd_development
# > db.dropDatabase();
puts "Dropping db #{db}"
system "mongo #{db} --eval 'db.dropDatabase()'"

# restore db
puts "Restoring #{db_archive_name} into #{db}"
system "mongorestore -d #{db} #{mongo_collection_path}"

# run model_report
scripts_dir = "/home/mhd/rails/lib/scripts/migrate_v2.0"
# rails r lib/scripts/model_report.rb > ~/model_report_pre_migrate.txt
puts "Pre migrate report"
load "#{scripts_dir}/model_report.rb"

# migrate db
puts "Migrating #{db} to 2.0"
system "mongo #{db} #{scripts_dir}/migrate_v2.0.js"

# run model_report again
puts "Post migrate report"
load "#{scripts_dir}/model_report.rb"

# dump db for clean start
hostname = Socket.gethostname
timestamp = Time.now.strftime "%Y%m%d%H%M%S"
dump_path = "#{working_directory}/#{hostname}-#{timestamp}"
puts "dumping migrated #{db} to #{dump_path}"
system "mongodump --out #{dump_path}"

# drop db
puts "dropping migrated #{db}"
system "mongo #{db} --eval 'db.dropDatabase()'"

# restore db
puts "Restoring #{dump_path} into #{db}"
system "mongorestore -d #{db} #{dump_path}/#{db}"

# index with mongoid rake task
puts "FINISHED"
puts "REMINDER:  rake db:mongoid:create_indexes"
