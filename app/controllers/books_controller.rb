# -*- coding: utf-8 -*-
class BooksController < ApplicationController
  # read by monogo id for backward compatibility
  def read_id
    id = params[:id]
    book = Book.find(id)
    @canonical_path = read_book_path(author: book.author, title: book.title) if book
    read_private(book, params[:page])
    #redirect_to read_book_url(author: book.author, title: book.title, page: params[:page]), status: 301
  end

  def read
    author = params[:author]
    title = params[:title]
    #TODO see if I need to use $exists or can query offline_at: nil
    book = Book.find_by(author: author, title: title, offline_at: {'$exists' => false})
    #TODO change to redirect_to :root, 301?  302? :notice => "book not found"
    read_private(book, params[:page])
  end

  def read_private(book, page)
    render_404 and return unless book
    @book = book
    @bookmark = current_user ? Bookmark.find_by({user_id: current_user.id, book_id: @book.id}) : nil
    @page = page ? page.to_i : @bookmark ? @bookmark.chunk : 1

    raise Unauthenticated.new(message: "Please register to continue reading.  Registration is free!", redirect_to: register_path, success_message: "Please check your email!  When you verify your email you receive one month of mihudie.com Free!", success_path: request.original_fullpath) if @page > 1 && !current_user

    #TODO This check works until I have an option to let them pay.  For the first month, all verified users will be premium.
    raise Unauthorized.new(message: "Verify email to continue reading.", redirect_to: account_registered_email_verify_notice_path, success_message: "Please check your email!  When you verify your email you receive one month of mihudie.com Free!", success_path: request.original_fullpath) if @page > 2 && !current_user.premium?

    #If user email not verified (they are on page 1 or 2). Show flash message directing them to verify email.  Can't get to page 3 without doing so.
    flash.now[:notice] = "#{view_context.link_to("Verify your email", account_registered_email_verify_notice_path)} for full access to all mihudie.com backyard books".html_safe if @page > 1 && !current_user.email_verified?

    begin
      path = @book.chunk_path(@page)
      logger.info "PATH: #{path}"
      @content = IO.read(path).html_safe
    rescue Errno::ENOENT
      #TODO need better error messgase here
      @content = "file not found: #{path}".html_safe
    end
    @chapter_title = @book.chapter_title(@page)
    @page_title = "#{@chapter_title} #{@book.title} - #{@book.author}"
    @page_description = "按近期被点击次数排行的电子书，在线阅读最吸引人的中文电子书"
    @page_keywords = "关注 流行 中文电子书 在线阅读"

    @book.increment_read_count if !current_user || !current_user.admin?
    @book.increment_unique_read_count if current_user && !@bookmark
    Bookmark.set(current_user, @book, @page) if current_user
    render "read", layout: "reading"
  end

  def list
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @sort = params[:sort] || 'popular'
    criteria = Book.online_popular if @sort == "popular"
    criteria = Book.online_recent if @sort == "recent"
    @books = criteria.page(@page)
    @page_title = "关注排行 电子书在线阅读"
    @page_description = "按近期被点击次数排行的电子书，在线阅读最吸引人的中文电子书"
    @page_keywords = "关注 流行 中文电子书 在线阅读"
  end

  def tag
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @tag = GenreTag.by_name(params[:tag])
    redirect_to(root_path, status: 301, notice: "tag #{@tag} does not exist") and return unless @tag
    @sort = params[:sort] || 'popular'
    criteria = Book.online_popular_by_tag(@tag) if @sort == "popular"
    criteria = Book.online_recent_by_tag(@tag) if @sort == "recent"
    @books = criteria.page(@page)
    @page_title = "#{@tag.cn} #{sort_cn(@sort)} page #{@page}"
    @page_description = "#{@tag.cn} 的言情小说在此应有尽有，最热门，最受关注的全本原创作品均在此陈列。喜欢此类故事的朋友一定能在此找到自己喜爱的书籍"
    @page_keywords = "#{@tag.cn}  言情小说  电子书  在线阅读"
  end

end
