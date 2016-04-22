class PagesController < ApplicationController
  before_action :find_page, only: :show
  before_action :links, only: :show
  before_action :translate, only: :show

  def index
    @pages = Page.all
  end

  def show
    gon.links = @existing_links.to_json
  end

  protected

    def find_page
      @page = Page.find(params[:id])
    end

    def links
      @existing_links = []
      @links = @page.page_links
      @links.each do |link|
        page = Page.find_by_url(link.url)
        @existing_links << page unless page == nil
      end
    end

    def translate
      @translation = Page.find_by_url(@page.translation)
    end

end
