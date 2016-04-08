class PagesController < ApplicationController
  before_action :find_page, only: :show
  before_action :links, only: :show
  before_action :translate, only: :show

  def index
    @pages = Page.all
  end

  def show
  end

  protected

    def find_page
      @page = Page.find(params[:id])
    end

    def links
      @links = @page.page_links
    end

    def translate
      @translate = PageLink.find(@page.translate)
    end

end
