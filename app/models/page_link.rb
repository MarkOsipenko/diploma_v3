class PageLink < ActiveRecord::Base
  validates :name, presence: true
  validates :url, presence: true, uniqueness: { message: "link exist" }, url: true
  # validates :url, format: { with: /\Ahttps:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_-]+\z/ }
  # before_save :enescape_link
  has_many :pages_page_links
  has_many :pages, through: :pages_page_links
  before_create :encoding_link

  def encoding_link
    self.url = URI::unescape(self.url)
  end

end