class Word < ActiveRecord::Base
  validates :definition, presence: true, uniqueness: { message: "word exist" }
  validates :content, presence: true
  validates :page_id, presence: true
  belongs_to :page

  class << self
    def search(query)
      where("definition like ?", "%#{query}%")
    end
  end

end