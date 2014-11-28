# dump mongodb
hostname = Socket.gethostname
timestamp = Time.now.strftime "%Y%m%d%H%M%S"
dump_path = "/home/mhd/mongo_dump/#{hostname}-#{timestamp}"
system "mongodump --out #{dump_path}"
