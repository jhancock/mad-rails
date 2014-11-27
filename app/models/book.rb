# -*- coding: utf-8 -*-
class Book
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  delegate :url_helpers, to: 'Rails.application.routes'

  field :title, type: String
  field :author, type: String
  field :summary, type: String
  #TODO need to store this as html_safe
  field :summary_html, type: String
  field :tags, type: Array, default: []
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

  # if set, this book is duplicate.  The master's id is the value of this field
  field :duplicate, type: BSON::ObjectId

  index({title: 1}, {unique: false})
  index({author: 1}, {unique: false})
  # A title/author pair is not unique.  Could represent a duplicate book.  Which is allowed.
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

  def set_offline_invalid_coding!(page)
    self.set(offline_at: Time.now)
    self.set(offline_reason: "invalid_utf8_encoding")
    SystemEvents.log(:book_invalid_utf8_encoding, {book_id: self.id, chunk: page})
  end

  def set_offline_file_not_found!(path)
    self.set(offline_at: Time.now)
    self.set(offline_reason: "file_not_found")
    SystemEvents.log(:book_file_not_found, {book_id: self.id, path: path})
  end

  #TODO no concept of chapters.  New model needed.
  def chapter_title(page)
    return nil if page == 1
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
    criteria = self.exists(title: true, author: true, offline_at: false)
    if Rails.configuration.mihudie.suppress_tags
      criteria = criteria.nin(tags: Rails.configuration.mihudie.suppress_tags)
    end
    criteria
  end

  #def self.find_for_read(author, title)
  #  book = nil
  #  books_criteria = self.online_criteria.where(author: author, title: title).desc(:created_at)
  #  count = books_criteria.count
  #  if count == 1
  #    book = books_criteria.first
  #  elsif count > 1
  #    book = self.merge_books(books_criteria)
  #  end
  #  book
  #end

  # if id is online but is duplicate, return the master if it is online.  otherwise return nil
  def self.find_for_read_by_id(id)
    book = self.find(id)
    if book && book.duplicate
      book = self.online_criteria.find_by(id: book.duplicate)
    end
    if book && !book.online?
      book = nil
    end
    book
  end

  # All books in books_criteria are assumed to be duplicates of one another.
  # books_criteria must be ordered so the first item is the default book to become master.
  # books_criteria.count should be greater than 1
  #def self.merge_books(books_criteria)
  #  master_book = nil
  #  books_criteria.each do |book|
  #    #TODO need to ensure ruby is doing what I think and master_book gets set correct
  #    master_book ||= book
  #    unless book.id == master_book.id
  #      # if book has summary and master_book does not, make book master
  #      if book.summary && !master_book.summary
  #        self.set_duplicate(book, master_book, true)
  #        master_book = book
  #      else
  #        self.set_duplicate(master_book, book, true)
  #      end
  #    end
  #  end
  #  master_book
  #end

  def self.set_master(book)
    book.unset(:duplicate)
    if book.offline_reason == "duplicate"
      book.unset(:offline_at)
      book.unset(:offline_reason)
    end
  end

  def self.set_duplicate(master, duplicate, merge_read_count = false)
    unless master.id == duplicate.id
      SystemEvents.log(:book_duplicate, {book_id: duplicate.id, master: master.id})
      self.set_master(master)
      master.inc(read_count: duplicate.read_count) if merge_read_count && duplicate.read_count
      master.inc(unique_read_count: duplicate.unique_read_count) if merge_read_count && duplicate.unique_read_count      
      duplicate.duplicate = master.id
      duplicate.offline_at = Time.now
      duplicate.offline_reason = "duplicate"
      duplicate.read_count = 0 if merge_read_count
      duplicate.unique_read_count = 0 if merge_read_count
      duplicate.save
      #fix broken bookmarks
      Bookmark.where(book_id: duplicate.id).update_all(book_id: master.id)
    end
  end

  def online?
    self.offline_at == nil
  end

  def chunk_path(chunk_id)
    "#{Rails.configuration.mihudie.books_path_prefix}#{self.id}/formatted/#{chunk_id}.html"
  end

  def create_detail_li 
    html = "<li><span>#{self.author}</span>".html_safe
    html << "<a href='#{url_helpers.read_book_path(author: self.author, title: self.title)}'>#{self.title}</a>".html_safe
    html << "<div class='detail-span'>".html_safe
    html << "#{self.summary_html}<br>".html_safe
    tag_ids = self.tags
    if (tag_ids.class == Array) && (tag_ids.length > 0)
      if tag_ids.length > 1
        tag_ids[0..-2].each do |tag_id|
          html << "<strong><a href='#{url_helpers.books_by_tag_path(tag: GenreTag.by_id(tag_id).name)}'>#{GenreTag.by_id(tag_id).cn}</a></strong>,&nbsp;".html_safe
        end
      end
      html << "<strong><a href='#{url_helpers.books_by_tag_path(tag: GenreTag.by_id(tag_ids[-1]).name)}'>#{GenreTag.by_id(tag_ids[-1]).cn}</a></strong>&nbsp;&ndash;&nbsp;".html_safe
    end
    html << "<strong>#{self.chars.to_s(:delimited)}</strong> 字数".html_safe
    html << "<div class='detail-span-action'>".html_safe
    html << "<a class='button-primary' href='#{url_helpers.read_book_path(author: self.author, title: self.title)}' rel='nofollow'>阅读</a>".html_safe
    html << "</div></div></li>".html_safe
    html.html_safe
  end

  def self.set_detail_li_all
    self.online_criteria.each do |book|
      book.detail_li = book.create_detail_li
      book.save
    end  
  end

end
