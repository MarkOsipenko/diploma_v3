class Word < ActiveRecord::Base
  validates :definition, presence: true, uniqueness: { message: "word exist" }
  validates :content, presence: true
  validates :page_id, presence: true
  belongs_to :page
end