db = Rails.env.production? ? "mhd_production" : "mhd_development"

# drop db
# from mongo shell command line:
# > mongo mhd_development
# > use mhd_development
# > db.dropDatabase();
system "mongo #{db} --eval 'db.dropDatabase()'"

# restore db
system "mongorestore ~/mongo_dump/lin1-20141102082738/#{db}"

