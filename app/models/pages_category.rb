class PagesCategory < ActiveRecord::Base
  belongs_to :page
  belongs_to :category
end
