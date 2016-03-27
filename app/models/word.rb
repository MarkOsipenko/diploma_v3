class Word < ActiveRecord::Base
  validates :name, presence: true, uniqueness: { message: "word exist" }
  validates :content, presence: true
  validates :page_id, presence: true
  belongs_to :page

  class << self
    def create_word(page)
      content = page.css("p").first
      name = page.css("p b").first.text
      content.children.each { |c| c.remove if c.name == 'b' }
      Word.create(name: name.capitalize, content: content.text)
    end
  end

end