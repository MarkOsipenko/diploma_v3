class PagesPageLink < ActiveRecord::Base
  belongs_to :page
  belongs_to :page_link
end
