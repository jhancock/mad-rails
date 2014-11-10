# -*- coding: utf-8 -*-
class BookmarksController < ApplicationController
  force_ssl
  before_action :ensure_user

  def index
    @page_title = "Bookmarks"
    @page_description = "按近期被点击次数排行的电子书，在线阅读最吸引人的中文电子书"
    @page_keywords = "关注 流行 中文电子书 在线阅读"
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @bookmarks = Bookmark.where(user_id: current_user.id).desc(:updated_at)
    if (@bookmarks.count - ((@page - 1) * 50)) < 1
      redirect_to bookmarks_path
    end
    @bookmarks = @bookmarks.page(@page)
  end

  #TODO if I delete bookmark #51, the redirect goes to page/2 which is not valid anymore.
  def delete
    bookmark = Bookmark.find(params[:bookmark_id])
    unless bookmark
      redirect_to root_path, :notice => "bookmark not found" and return
    end
    bookmark.delete if bookmark
    flash[:notice] = "bookmark deleted for #{bookmark.book.title}"
    referer = request.env["HTTP_REFERER"]
    if referer
      redirect_to :back
    else
      redirect_to bookmarks_path
    end
  end
end
