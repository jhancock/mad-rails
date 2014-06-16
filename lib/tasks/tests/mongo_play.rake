namespace :mhd do
	desc "mongodb playground"
	task book_show_email_errors: :environment do

	Book.find

  		models = [Book, User]
  		models.each do | model |
	  		puts "collection: #{model} count: #{model.count}"
	  		@attribute_counts = {}
			model.each do |document|
				document.attributes.each do | key, value |
					if not @attribute_counts.has_key? key
						@attribute_counts[key] = 0
					end
					@attribute_counts[key] = @attribute_counts[key] + 1
				end
			end
			#puts @attribute_counts
			@fields = model.fields
			@attributes_missing = @attribute_counts.select {|k,v| not @fields.has_key? k }
			puts "missing fields: #{@attributes_missing}"
			puts "======================================"
		end
  	end
end
