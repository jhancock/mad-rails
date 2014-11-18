# -*- coding: utf-8 -*-
class BookmarksController < ApplicationController
  force_ssl
  before_action :ensure_user

  def index
    @page_title = "书签"
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @bookmarks = Bookmark.where(user_id: current_user.id).desc(:updated_at).page(@page)
    if (@bookmarks.count == 0) && (@page == 1)
      render and return
    end
    if ((@bookmarks.count == 0) && (@page != 1)) || ((@bookmarks.count - ((@page - 1) * 50)) < 1) 
      redirect_to bookmarks_path and return
    end
  end

  def delete
    bookmark = Bookmark.find(params[:bookmark_id])
    unless bookmark
      redirect_to root_path, :notice => "书签没有找到" and return
    end
    bookmark.delete if bookmark
    flash[:notice] = "#{bookmark.book.title} - 书签已经删除"
    redirect_back_or bookmarks_path
  end
end
