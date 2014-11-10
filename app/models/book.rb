# -*- coding: utf-8 -*-
class Book
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  field :title, type: String
  field :author, type: String
  field :summary, type: String
  # need to store this as html_safe
  field :summary_html, type: String
  field :tags, type: Array, default: []
  field :tag_names, type: Array, default: []
  field :tag_names_pp, type: String
  # pre-rendered li of the book for detail-span
  field :detail_li, type: String

  field :origin, type: String
  field :type, type: String
  field :chars, type: Integer
  field :chunks, type: Integer
  field :read_count, type: Integer, default: 0
  field :unique_read_count, type: Integer, default: 0

  # should default to nil?  or change this to a state field?
  field :offline_at, type: Time
  field :offline_reason, type: String

  index({title: 1}, {unique: false})
  index({author: 1}, {unique: false})
  index({ title: 1, author: 1, offline_at: 1 }, { unique: false })
  index({ title: 1, author: 1, offline_at: 1, tags: 1 }, { unique: false })
  index({tags: 1}, {unique: false})
  index({offline_at: -1}, {unique: false})
  index({updated_at: -1}, {unique: false})
  index({read_count: -1}, {unique: false})
  index({unique_read_count: -1}, {unique: false})
  
  #after_create :index_document
  #TODO do not want to do this when only read_count is updated
  #after_update :update_document
  #after_upsert :update_document
  #after_destroy :delete_document

  #after_save    { Indexer.perform_async(:index,  self.id) }
  #after_destroy { Indexer.perform_async(:delete, self.id) }

  # Delete everything
  # Book.__elasticsearch__.client.indices.delete index: Book.index_name rescue nil
  # will delete and recreate index?
  # Book.__elasticsearch__.create_index! force: true
  # Book.import
  # response = Book.search '如花春梦'
  # response.results.total
  # response.results.first._score
  # response.results.first.id
  # response.results.first.title
  # response.results.first._source.title
  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      #indexes :title, type: 'string', analyzer: 'smartcn', index_options: 'offsets'
      indexes :title, type: 'string', analyzer: 'smartcn', store: 'true', term_vector: 'with_positions_offsets'
      indexes :author, type: 'string', analyzer: 'smartcn', store: 'true', term_vector: 'with_positions_offsets'
      indexes :summary, type: 'string', analyzer: 'smartcn', store: 'true', term_vector: 'with_positions_offsets'
      indexes :tag_names_pp, type: 'string', analyzer: 'smartcn', store: 'true', term_vector: 'with_positions_offsets'
      indexes :offline_at
      indexes :chars, type: 'integer'
    end
  end

  def as_indexed_json(options={})
    as_json(only: [:title, :author, :summary, :tag_names_pp, :offline_at, :chars])
  end

  def self.search(query)
    __elasticsearch__.search(
       {
         query: {
           filtered: {
             query: {
               multi_match: {
                 query: query,
                 fields: ['title^2', 'author^2', 'tag_names_pp', 'summary']
               }
             },
             filter: {
               missing: {
                 field: 'offline_at',
                 existence: true,
                 null_value: true
               }
             }
           }
         },
         highlight: {
           pre_tags: ['<em>'],
           post_tags: ['</em>'],
           fields: {
             title: {},
             author: {},
             tag_names_pp: {},
             summary: {}
           }
         }
       }
     )
  end

  #TODO no concept of chapters.  New model needed.
  def chapter_title(page)
    "第#{page}页"
  end

  def increment_read_count
    self.inc(read_count: 1)
  end

  def increment_unique_read_count
    self.inc(unique_read_count: 1)
  end

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

  def online?
    self.offline_at == nil
  end

  def chunk_path(chunk_id)
    "#{Rails.configuration.mihudie.books_path_prefix}#{self.id}/formatted/#{chunk_id}.html"
  end
end
