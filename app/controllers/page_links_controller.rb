class PageLinksController < ApplicationController
  def index
    @pagelinks = PageLink.all
  end

end
