class Category < ActiveRecord::Base
  validates :name, presence: true, uniqueness: { message: "category exist" }
  has_many :pages_categories
  has_many :pages, through: :pages_categories
end
