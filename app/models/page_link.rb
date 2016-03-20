class PageLink < ActiveRecord::Base
  validates :name, presence: true
  validates :url, presence: true, uniqueness: { message: "link exist" }, url: true
  # validates :url, format: { with: /\Ahttps:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_-]+\z/ }
  # before_save :enescape_link
  before_create :encoding_link

  def encoding_link
    self.url = URI::unescape(self.url)
  end

  def link_format
    true if /^https:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_-]+$/ === self.url
  end
end