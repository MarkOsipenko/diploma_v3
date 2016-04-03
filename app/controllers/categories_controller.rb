class CategoriesController < ApplicationController
  before_action :find_category, only: :show
  
  def index
    @categories = Categories.all
  end

  def show
    @pages = @category.pages
  end

  protected

    def find_category
      @category = Category.find(params[:id])
    end

end
