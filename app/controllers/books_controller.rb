# -*- coding: utf-8 -*-
class BooksController < ApplicationController
  # read by monogo id for backward compatibility and completeness
  def read_id
    id = params[:id]
    book = Book.find(id)
    render_404 and return unless book
    redirect_to read_book_url(author: book.author, title: book.title, page: params[:page]), status: 301
  end

  def read()
    author = params[:author]
    title = params[:title]
    #TODO verify that if offline_at exists but is nil this behaves as expected.
    @book = Book.find_by(author: author, title: title, offline_at: {'$exists' => false})
    render_404 and return unless @book
    @page = params[:page] ? params[:page].to_i : 1
    begin
      path = @book.chunk_path(@page)
      logger.info "PATH: #{path}"
      @content = IO.read(path).html_safe
    rescue Errno::ENOENT
      #TODO need better error messgase here
      @content = "file not found: #{path}".html_safe
    end
    if @page == 1
      @page_title = "#{@book.title} - #{@book.author}"
    else
      @page_title = "第#{@page}页 #{@book.title} - #{@book.author}"
    end
    @page_description = "按近期被点击次数排行的电子书，在线阅读最吸引人的中文电子书"
    @page_keywords = "关注 流行 中文电子书 在线阅读"
    render layout: "reading"
  end

  def list()
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @sort = params[:sort] || 'popular'
    criteria = Book.online_popular if @sort == "popular"
    criteria = Book.online_recent if @sort == "recent"
    @books = criteria.page(@page)
    @page_title = "关注排行 电子书在线阅读"
    @page_description = "按近期被点击次数排行的电子书，在线阅读最吸引人的中文电子书"
    @page_keywords = "关注 流行 中文电子书 在线阅读"
  end

  def tag()
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @tag = GenreTag.by_name(params[:tag])
    render_404 and return unless @tag
    @sort = params[:sort] || 'popular'
    criteria = Book.online_popular_by_tag(@tag) if @sort == "popular"
    criteria = Book.online_recent_by_tag(@tag) if @sort == "recent"
    @books = criteria.page(@page)
    page_title = "#{@tag.cn} 电子书在线阅读"
    page_description = "#{@tag.cn} 的言情小说在此应有尽有，最热门，最受关注的全本原创作品均在此陈列。喜欢此类故事的朋友一定能在此找到自己喜爱的书籍"
    page_keywords = "#{@tag.cn}  言情小说  电子书  在线阅读"
  end

end
