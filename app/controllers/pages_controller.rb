class PagesController < ApplicationController
  before_action :find_page, only: :show
  before_action :links, only: :show

  def show
  end


  protected

    def find_page
      @page = Page.find(params[:id])
    end


    def links
      @links = @page.page_links
    end

end
