namespace :mhd do
	desc "mongodb playground"
	task mongo_play2: :environment do
	
		# mongo shell > db.users.find({email_error: {$exists: true}}
		# criteria = User.where(:email_error => {"$exists"=>true})
		criteria = Book.where("author"=>"清歌一片", "title"=>"金炉小篆香断尽")
		puts "==============="
		puts criteria.inspect
		puts "==============="
		puts "count: #{criteria.count}"
		puts "attributes: #{criteria.first.attributes}"
		#criteria.each do | doc |
		#	puts doc.attributes
		#end
	end
end
