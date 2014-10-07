class SearchController < ApplicationController
  
  def search

  end

  def search_post
    if params[:query].nil?
      @books = []
    else
      @books = Book.search params[:query]
    end
    render 'search'
  end
end
