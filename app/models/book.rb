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

  # should default to nil?  or change this to a state field?
  field :offline_at, type: Time
  field :offline_reason, type: String

  index({ title: 1, author: 1, offline_at: 1 }, { unique: false })
  index title: 1
  index author: 1
  index offline_at: 1
  index updated_at: -1
  index read_count: -1

  def self.online_recent
    self.online_criteria.desc(:updated_at)
  end

  def self.online_popular
    self.online_criteria.desc(:read_count)
  end

  def self.online_recent_by_tag(tag)
    self.online_recent.in(tags: tag.id)
  end

  def self.online_popular_by_tag(tag)
    self.online_popular.in(tags: tag.id)
  end

  def self.online_criteria
    criteria = Book.exists(title: true, author: true, offline_at: false)
    if Rails.configuration.mihudie.suppress_tags
      criteria = criteria.nin(tags: Rails.configuration.mihudie.suppress_tags)
    end
    criteria
  end

  def chunk_path(chunk_id)
    "#{Rails.configuration.mihudie.books_path_prefix}#{self.id}/formatted/#{chunk_id}.html"
  end
end
