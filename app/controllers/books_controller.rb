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
		@book = Book.find_by(author: author, title: title, offline_at: {'$exists' => false})
		render_404 and return unless @book
		@page = params[:page] ? params[:page].to_i : 1
		begin
			path = @book.chunk_path(@page)
			logger.info "PATH: #{path}"
      		@content = IO.read(path)
    	rescue Errno::ENOENT
      		@content = "file not found: #{path}"
    	end
    	render
	end
	
	def recent()
		@page = params[:page].to_i > 0 ? params[:page].to_i : 1
		@books = Book.public_recent_criteria.page(@page)
		@page_title = "关注排行 电子书在线阅读"
    	@page_description = "按近期被点击次数排行的电子书，在线阅读最吸引人的中文电子书"
    	@page_keywords = "关注 流行 中文电子书 在线阅读"
	end

	def popular()
		@page = params[:page].to_i > 0 ? params[:page].to_i : 1
		@books = Book.public_popular_criteria.page(@page)
		@page_title = "热门书籍排行 电子书在线阅读"
    	@page_description = "按被点击次数高低的书籍排行，在线阅读最热门的中文电子书"
    	@page_keywords = "热门 流行 中文电子书 在线阅读"
	end

end
