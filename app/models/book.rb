class Book
	include Mongoid::Document
	include Mongoid::Timestamps

	field :title, type: String
	field :author, type: String
	field :summary, type: String
	field :summary_html, type: String
	field :tags, type: Array, default: []
	field :tag_names, type: Array, default: []
	field :tag_names_pp, type: String

	field :origin, type: String
	field :type, type: String
	field :chars, type: Integer
	field :chunks, type: Integer
	field :read_count, type: Integer, default: 0

	field :offline_at, type: Time
	#TODO verify type.  be able to query for a model without this attribute existing 
	field :offline_reason, type: String
end
