models = [User, Book, Bookmark, BookUpload]
puts "======  Model & MongoDB report ======"
puts ""
models.each do | model |
  #puts "============================================="
  puts "=== model: #{model}, db: #{model.collection.name}, docs: #{model.count}"
  @attribute_counts = {}
  model.each do |document|
    document.attributes.each do | key, value |
      if not @attribute_counts.has_key? key
        @attribute_counts[key] = 0
      end
      @attribute_counts[key] = @attribute_counts[key] + 1
    end
  end
  puts "============================================="
  puts "=== db field counts:"
  puts @attribute_counts
  @fields = model.fields
  @fields_pp = @fields.collect { |each| "#{each[1].name} => #{each[1].options[:type]}"}
  @attributes_missing = @attribute_counts.select {|k,v| not @fields.has_key? k }
  puts "============================================="
  puts "=== #{model} fields defined:"
  puts "#{@fields_pp}"
  puts "============================================="
  puts "=== db: #{model.collection.name} contains fields missing in #{model}:"
  puts "#{@attributes_missing}"
  puts "============================================="
  puts ""
end
