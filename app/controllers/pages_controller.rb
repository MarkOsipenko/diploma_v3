class PagesController < ApplicationController
  before_action :find_page, only: :show
  before_action :get_links_and_words, only: :show
  before_action :translate, only: :show
  before_action :word, only: :show

  def index
    @pages = Page.all
  end

  def show
    gon.links = @existing_pages.to_json
    gon.page = @page.to_json
    gon.word = @word.to_json
    gon.words = @words.to_json
    gon.arrayPageLinksPageAssociation = @links_to_page.to_json
  end

  protected

    def find_page
      @page = Page.find(params[:id])
    end

    def get_links_and_words
      @existing_pages = []
      @words  = []
      @links_to_page = {}
      @links = @page.page_links

      @links.each do |link|
        page = Page.find_by_url(link.url)
        @links_to_page[:"#{page.id}"] = page.page_links.ids unless page == nil
        @existing_pages << page unless page == nil
        @words << page.word unless page == nil
      end
    end

    def word
      @word = @page.word
    end

    def translate
      @translation = Page.find_by_url(@page.translation)
    end

end
