class WordsController < ApplicationController

  def index
    if params[:search]
     @words = Word.search(params[:search].mb_chars.capitalize).order("created_at ASC").paginate(page: params[:page], per_page: 30)
    else
     @words = Word.order("created_at ASC").paginate(page: params[:page], per_page: 30)
    end
  end

end
