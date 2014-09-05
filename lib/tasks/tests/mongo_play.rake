namespace :mhd do
	desc "mongodb playground"
	task mongo_play: :environment do
	
		# mongo shell > db.users.find({email_error: {$exists: true}}
		# criteria = User.where(:email_error => {"$exists"=>true})
		criteria = Book.exists(title: true, author: true, offline_at: false).desc(:updated_at)
		puts "==============="
		puts criteria.inspect
		puts "==============="
		puts "count: #{criteria.count}"
		#criteria.each do | doc |
		#	puts doc.attributes
		#end
	end
end