class SearchController < ApplicationController
  
  def search
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @query = params[:query]
    if @query.nil?
      @books = []
    else
      @books = Book.search(params[:query]).records
    end
  end
end
